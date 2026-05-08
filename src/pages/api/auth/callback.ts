import type { APIRoute } from 'astro';
import { obtenerClienteSuperbase } from '../../../lib/supabaseClient';

/**
 * Callback de Google OAuth — Plataforma SED-360
 *
 * Recibe el código de autorización de Google, lo intercambia por
 * una sesión de Supabase, establece las cookies y redirige al
 * dashboard del evaluador.
 *
 * Ruta pública (ver middleware.ts — RUTAS_PUBLICAS).
 */
export const GET: APIRoute = async ({ url, cookies, redirect }) => {
  const code = url.searchParams.get('code');
  const errorParam = url.searchParams.get('error');
  const errorDescription = url.searchParams.get('error_description');

  console.log('[SED-360 Callback] URL completa:', url.toString());
  console.log('[SED-360 Callback] Code presente:', !!code);

  // Si hay error explícito de Google/Supabase
  if (errorParam) {
    console.error('[SED-360 Callback] Error OAuth:', errorParam, errorDescription);
    return redirect('/auth?error=oauth');
  }

  // Si no hay código, redirigir con mensaje
  if (!code) {
    console.error('[SED-360 Callback] No se recibió código de autorización');
    return redirect('/auth?error=oauth');
  }

  try {
    const cliente = obtenerClienteSuperbase();
    const { data, error } = await cliente.auth.exchangeCodeForSession(code);

    if (error || !data.session) {
      console.error('[SED-360 Callback] Error al intercambiar código:', error?.message);
      return redirect('/auth?error=oauth');
    }

    const { access_token: tokenAcceso, refresh_token: tokenRefresco } = data.session;

    // Establecer cookies de sesión (coinciden con las que lee el middleware)
    // secure: false en desarrollo (localhost HTTP), true en producción
    const esProduccion = import.meta.env.PROD;

    cookies.set('sb-access-token', tokenAcceso, {
      path: '/',
      httpOnly: true,
      secure: esProduccion,
      sameSite: 'lax',
      maxAge: 60 * 60 * 24 * 7, // 1 semana
    });

    cookies.set('sb-refresh-token', tokenRefresco, {
      path: '/',
      httpOnly: true,
      secure: esProduccion,
      sameSite: 'lax',
      maxAge: 60 * 60 * 24 * 7,
    });

    return redirect('/evaluador');
  } catch (err) {
    console.error('[SED-360 Callback] Error inesperado:', err);
    return redirect('/auth?error=oauth');
  }
};
