drop policy if exists "avatars_select_own" on storage.objects;
create policy "avatars_select_own"
on storage.objects
for select
to authenticated
using (
	bucket_id = 'avatars'
	and split_part(name, '/', 1) = regexp_replace((select auth.jwt() ->> 'sub'), '[^A-Za-z0-9._-]', '_', 'g')
);

drop policy if exists "avatars_insert_own" on storage.objects;
create policy "avatars_insert_own"
on storage.objects
for insert
to authenticated
with check (
	bucket_id = 'avatars'
	and split_part(name, '/', 1) = regexp_replace((select auth.jwt() ->> 'sub'), '[^A-Za-z0-9._-]', '_', 'g')
);

drop policy if exists "avatars_update_own" on storage.objects;
create policy "avatars_update_own"
on storage.objects
for update
to authenticated
using (
	bucket_id = 'avatars'
	and split_part(name, '/', 1) = regexp_replace((select auth.jwt() ->> 'sub'), '[^A-Za-z0-9._-]', '_', 'g')
)
with check (
	bucket_id = 'avatars'
	and split_part(name, '/', 1) = regexp_replace((select auth.jwt() ->> 'sub'), '[^A-Za-z0-9._-]', '_', 'g')
);
