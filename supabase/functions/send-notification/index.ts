import { createClient } from '@supabase/supabase-js'
import { serve } from 'std/http/server.ts'

const ONE_SIGNAL_APP_ID = Deno.env.get('ONE_SIGNAL_APP_ID')!
const ONE_SIGNAL_API_KEY = Deno.env.get('ONE_SIGNAL_API_KEY')!

serve(async (req: Request) => {
  try {
    const { recipient_user_id, title, body } = await req.json()

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    let playerId: string | null = null;
    let notificationsEnabled: boolean = true;

    // Check if the recipient is a medical partner
    const { data: partnerData } = await supabaseAdmin
      .from('medical_partners')
      .select('onesignal_player_id, notifications_enabled')
      .eq('id', recipient_user_id)
      .single();

    if (partnerData && partnerData.onesignal_player_id) {
      playerId = partnerData.onesignal_player_id;
      notificationsEnabled = partnerData.notifications_enabled ?? true;
    } else {
      // It's a regular user, so check the 'users' table
      const { data: userData } = await supabaseAdmin
        .from('users')
        .select('onesignal_player_id, notifications_enabled')
        .eq('id', recipient_user_id)
        .single();
      
      if (userData && userData.onesignal_player_id) {
        playerId = userData.onesignal_player_id;
        notificationsEnabled = userData.notifications_enabled ?? true;
      }
    }

    if (playerId && notificationsEnabled) {
      await fetch('https://onesignal.com/api/v1/notifications', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Basic ${ONE_SIGNAL_API_KEY}`,
        },
        body: JSON.stringify({
          app_id: ONE_SIGNAL_APP_ID,
          include_player_ids: [playerId],
          headings: { en: title },
          contents: { en: body },
        }),
      });
    }

    return new Response(JSON.stringify({ success: true }), {
      headers: { 'Content-Type': 'application/json' },
    });

  } catch (error) {
    if (error instanceof Error) {
      return new Response(JSON.stringify({ error: error.message }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' },
      });
    }
    return new Response(JSON.stringify({ error: 'An unknown error occurred.' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
});