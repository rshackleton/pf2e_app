drop policy if exists "avatars_delete_own" on storage.objects;
create policy "avatars_delete_own"
on storage.objects
for delete
to authenticated
using (
	bucket_id = 'avatars'
	and split_part(name, '/', 1) = regexp_replace((select auth.jwt() ->> 'sub'), '[^A-Za-z0-9._-]', '_', 'g')
);
