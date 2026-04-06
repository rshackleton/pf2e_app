'use strict';

/**
 * Handler that will be called during the execution of a PostUserRegistration flow.
 *
 * @param {Event} event - Details about the context and user that has registered.
 * @param {PostUserRegistrationAPI} api - Interface whose methods can be used to change the behavior of post user registration.
 */
exports.onExecutePostUserRegistration = async (event, api) => {
  const { createClient } = require('@supabase/supabase-js');

  const supabaseUrl = event.secrets.SUPABASE_URL;
  const supabaseSecretKey = event.secrets.SUPABASE_SECRET_KEY;

  if (!supabaseUrl || !supabaseSecretKey) {
    console.log('Missing required Supabase Action secrets.');
    return;
  }

  const userId = event.user?.user_id;
  if (!userId) {
    console.log('Missing Auth0 user_id (sub) in registration event.');
    return;
  }

  const payload = {
    user_id: userId,
    first_name: event.user?.given_name ?? null,
    last_name: event.user?.family_name ?? null,
  };

  const supabase = createClient(supabaseUrl, supabaseSecretKey);

  const result = await supabase
    .from('profiles')
    .insert(payload)
    .select();

  if (!result.data) {
    console.log(`Profile provisioning failed: ${result.status} ${result.statusText}`);
  }
};
