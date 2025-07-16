revoke select on table "auth"."schema_migrations" from "postgres";


grant delete on table "storage"."s3_multipart_uploads" to "postgres";

grant insert on table "storage"."s3_multipart_uploads" to "postgres";

grant references on table "storage"."s3_multipart_uploads" to "postgres";

grant select on table "storage"."s3_multipart_uploads" to "postgres";

grant trigger on table "storage"."s3_multipart_uploads" to "postgres";

grant truncate on table "storage"."s3_multipart_uploads" to "postgres";

grant update on table "storage"."s3_multipart_uploads" to "postgres";

grant delete on table "storage"."s3_multipart_uploads_parts" to "postgres";

grant insert on table "storage"."s3_multipart_uploads_parts" to "postgres";

grant references on table "storage"."s3_multipart_uploads_parts" to "postgres";

grant select on table "storage"."s3_multipart_uploads_parts" to "postgres";

grant trigger on table "storage"."s3_multipart_uploads_parts" to "postgres";

grant truncate on table "storage"."s3_multipart_uploads_parts" to "postgres";

grant update on table "storage"."s3_multipart_uploads_parts" to "postgres";

create policy "allow all 6odaj1_0"
on "storage"."objects"
as permissive
for select
to authenticated
using ((bucket_id = 'chat-images'::text));


create policy "allow all 6odaj1_1"
on "storage"."objects"
as permissive
for insert
to authenticated
with check ((bucket_id = 'chat-images'::text));


create policy "allow all 6odaj1_2"
on "storage"."objects"
as permissive
for update
to authenticated
using ((bucket_id = 'chat-images'::text));


create policy "allow all 6odaj1_3"
on "storage"."objects"
as permissive
for delete
to authenticated
using ((bucket_id = 'chat-images'::text));



