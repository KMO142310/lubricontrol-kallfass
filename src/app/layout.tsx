import type { Metadata, Viewport } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import { AuthProvider } from "@/lib/auth/auth-context";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "LubriControl — Sistema de Lubricación Industrial",
  description: "Plataforma de inteligencia de campo para gestión de lubricación en aserradero Kallfass. Control de rutas, gramajes, anomalías y consumo de lubricantes ESMAX LUBRAX.",
  manifest: "/manifest.json",
  keywords: ["lubricación", "mantenimiento", "aserradero", "Kallfass", "ESMAX", "industrial"],
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  maximumScale: 1,
  userScalable: false,
  themeColor: "#0a0e17",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="es">
      <body className={inter.className}>
        <AuthProvider>
          {children}
        </AuthProvider>
      </body>
    </html>
  );
}
