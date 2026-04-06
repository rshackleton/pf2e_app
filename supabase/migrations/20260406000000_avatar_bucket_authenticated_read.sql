-- Make the avatars bucket non-public so objects require authentication to access.
update storage.buckets
set public = false
where id = 'avatars';

-- Replace owner-only select policy with one that allows any authenticated user
-- to read avatars (e.g. to display other users' avatars in shared contexts).
drop policy if exists "avatars_select_own" on storage.objects;
create policy "avatars_select_authenticated"
on storage.objects
for select
to authenticated
using (
	bucket_id = 'avatars'
);
