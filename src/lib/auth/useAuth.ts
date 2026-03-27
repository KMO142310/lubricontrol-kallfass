import { useAuth as useAuthInternal } from './auth-context';

export function useAuth() {
  const { user, profile, isLoading, signOut } = useAuthInternal();

  return {
    user,
    profile,
    isLoading,
    signOut,
    isAdmin: profile?.role === 'admin',
    isSupervisor: profile?.role === 'supervisor',
    isLubricator: profile?.role === 'lubricator',
    role: profile?.role,
  };
}
