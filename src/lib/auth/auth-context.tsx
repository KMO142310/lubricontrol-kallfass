'use client';

import { createContext, useContext, useEffect, useState } from 'react';
import { User } from '@supabase/supabase-js';
import { createClient } from '@/lib/supabase/client';
import type { Profile } from '@/types/database';

interface AuthContextType {
  user: User | null;
  profile: Profile | null;
  isLoading: boolean;
  signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType>({
  user: null,
  profile: null,
  isLoading: true,
  signOut: async () => {},
});

export function AuthProvider({ children }: { readonly children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [profile, setProfile] = useState<Profile | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const supabase = createClient();

  useEffect(() => {
    let mounted = true;

    async function loadUser() {
      // Dev Bypass Logic
      const isDevBypass = process.env.NODE_ENV === 'development' && window.location.search.includes('bypass=true');
      
      if (isDevBypass) {
        console.log('🛡️ Auth Bypass Active (Dev Mode)');
        const mockUser = {
          id: 'dev-user-id',
          email: 'lubricador1@planta.local',
          user_metadata: { role: 'lubricador' }
        } as any;
        const mockProfile = {
          id: 'dev-user-id',
          email: 'lubricador1@planta.local',
          role: 'lubricador',
          full_name: 'Lubricador de Pruebas',
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        } as any;
        
        setUser(mockUser);
        setProfile(mockProfile);
        setIsLoading(false);
        return;
      }

      try {
        const { data: { session } } = await supabase.auth.getSession();
        
        if (session?.user) {
          if (mounted) setUser(session.user);
          
          // Fetch profile for role
          const { data: profileData } = await supabase
            .from('profiles')
            .select('*')
            .eq('id', session.user.id)
            .single();
            
          if (mounted && profileData) {
            setProfile(profileData as Profile);
          }
        }
      } catch (error) {
        console.error('Error loading auth state:', error);
      } finally {
        if (mounted) setIsLoading(false);
      }
    }

    loadUser();

    const { data: { subscription } } = supabase.auth.onAuthStateChange(async (event, session) => {
      setUser(session?.user ?? null);
      if (session?.user) {
        const { data: profileData } = await supabase
          .from('profiles')
          .select('*')
          .eq('id', session.user.id)
          .single();
        if (mounted && profileData) {
          setProfile(profileData as Profile);
        }
      } else {
        setProfile(null);
      }
      setIsLoading(false);
    });

    return () => {
      mounted = false;
      subscription.unsubscribe();
    };
  }, [supabase]);

  const signOut = async () => {
    await supabase.auth.signOut();
  };

  return (
    <AuthContext.Provider value={{ user, profile, isLoading, signOut }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}
