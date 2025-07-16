

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE OR REPLACE FUNCTION "public"."log_profile_health_changes"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
    BEGIN
        IF OLD.height_cm IS DISTINCT FROM NEW.height_cm OR OLD.weight_kg IS DISTINCT FROM NEW.weight_kg THEN
            INSERT INTO health_history (user_id, height_cm, weight_kg, change_timestamp)
            VALUES (OLD.user_id, OLD.height_cm, OLD.weight_kg, CURRENT_TIMESTAMP);
        END IF;
        NEW.updated_at = CURRENT_TIMESTAMP;
        RETURN NEW;
    END;
    $$;


ALTER FUNCTION "public"."log_profile_health_changes"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."alembic_version" (
    "version_num" character varying(128) NOT NULL
);


ALTER TABLE "public"."alembic_version" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."comments" (
    "id" bigint NOT NULL,
    "post_id" bigint NOT NULL,
    "user_id" bigint NOT NULL,
    "content" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "public"."comments" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."comments_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."comments_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."comments_id_seq" OWNED BY "public"."comments"."id";



CREATE TABLE IF NOT EXISTS "public"."conversations" (
    "id" bigint NOT NULL,
    "user_id" bigint NOT NULL,
    "title" character varying(255),
    "status" character varying(50) DEFAULT 'active'::character varying NOT NULL,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "extra_data" "jsonb",
    CONSTRAINT "valid_status" CHECK ((("status")::"text" = ANY (ARRAY[('active'::character varying)::"text", ('archived'::character varying)::"text", ('deleted'::character varying)::"text"])))
);


ALTER TABLE "public"."conversations" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."conversations_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."conversations_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."conversations_id_seq" OWNED BY "public"."conversations"."id";



CREATE TABLE IF NOT EXISTS "public"."dish_ingredients" (
    "id" bigint NOT NULL,
    "dish_id" bigint NOT NULL,
    "ingredient_id" bigint NOT NULL,
    "quantity" numeric(10,2) NOT NULL
);


ALTER TABLE "public"."dish_ingredients" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."dish_ingredients_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."dish_ingredients_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."dish_ingredients_id_seq" OWNED BY "public"."dish_ingredients"."id";



CREATE TABLE IF NOT EXISTS "public"."dishes" (
    "id" bigint NOT NULL,
    "name" character varying(100) NOT NULL,
    "description" "text",
    "cuisine" character varying(50),
    "created_by_user_id" bigint,
    "cooking_steps" "text"[],
    "prep_time_minutes" integer,
    "cook_time_minutes" integer,
    "image_urls" character varying(255)[],
    "servings" integer,
    "calories" numeric(10,2),
    "protein_g" numeric(10,2),
    "carbs_g" numeric(10,2),
    "fats_g" numeric(10,2),
    "sat_fats_g" numeric(10,2),
    "unsat_fats_g" numeric(10,2),
    "trans_fats_g" numeric(10,2),
    "fiber_g" numeric(10,2),
    "sugar_g" numeric(10,2),
    "calcium_mg" numeric(10,2),
    "iron_mg" numeric(10,2),
    "potassium_mg" numeric(10,2),
    "sodium_mg" numeric(10,2),
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "zinc_mg" numeric(10,2),
    "magnesium_mg" numeric(10,2),
    "vit_a_mcg" numeric(10,2),
    "vit_b1_mg" numeric(10,2),
    "vit_b2_mg" numeric(10,2),
    "vit_b3_mg" numeric(10,2),
    "vit_b5_mg" numeric(10,2),
    "vit_b6_mg" numeric(10,2),
    "vit_b9_mcg" numeric(10,2),
    "vit_b12_mcg" numeric(10,2),
    "vit_c_mg" numeric(10,2),
    "vit_d_mcg" numeric(10,2),
    "vit_e_mg" numeric(10,2),
    "vit_k_mcg" numeric(10,2)
);


ALTER TABLE "public"."dishes" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."dishes_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."dishes_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."dishes_id_seq" OWNED BY "public"."dishes"."id";



CREATE TABLE IF NOT EXISTS "public"."fitness_plans" (
    "id" bigint NOT NULL,
    "user_id" bigint NOT NULL,
    "goal_type" character varying(50) NOT NULL,
    "target_weight_kg" numeric(5,2),
    "target_calories_per_day" integer,
    "start_date" "date" NOT NULL,
    "end_date" "date" NOT NULL,
    "suggestions" "jsonb",
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "public"."fitness_plans" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."fitness_plans_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."fitness_plans_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."fitness_plans_id_seq" OWNED BY "public"."fitness_plans"."id";



CREATE TABLE IF NOT EXISTS "public"."health_history" (
    "id" bigint NOT NULL,
    "user_id" bigint NOT NULL,
    "height_cm" numeric(6,2),
    "weight_kg" numeric(6,2),
    "change_timestamp" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE "public"."health_history" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."health_history_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."health_history_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."health_history_id_seq" OWNED BY "public"."health_history"."id";



CREATE TABLE IF NOT EXISTS "public"."ingredients" (
    "id" bigint NOT NULL,
    "name" character varying(100) NOT NULL,
    "serving_size" numeric(10,2) NOT NULL,
    "calories" numeric(10,2),
    "protein_g" numeric(10,2),
    "carbs_g" numeric(10,2),
    "fats_g" numeric(10,2),
    "sat_fats_g" numeric(10,2),
    "unsat_fats_g" numeric(10,2),
    "trans_fats_g" numeric(10,2),
    "fiber_g" numeric(10,2),
    "sugar_g" numeric(10,2),
    "calcium_mg" numeric(10,2),
    "iron_mg" numeric(10,2),
    "potassium_mg" numeric(10,2),
    "sodium_mg" numeric(10,2),
    "zinc_mg" numeric(10,2),
    "magnesium_mg" numeric(10,2),
    "vit_a_mcg" numeric(10,2),
    "vit_b1_mg" numeric(10,2),
    "vit_b2_mg" numeric(10,2),
    "vit_b3_mg" numeric(10,2),
    "vit_b5_mg" numeric(10,2),
    "vit_b6_mg" numeric(10,2),
    "vit_b9_mcg" numeric(10,2),
    "vit_b12_mcg" numeric(10,2),
    "vit_c_mg" numeric(10,2),
    "vit_d_mcg" numeric(10,2),
    "vit_e_mg" numeric(10,2),
    "vit_k_mcg" numeric(10,2),
    "image_url" character varying(255),
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "public"."ingredients" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."ingredients_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."ingredients_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."ingredients_id_seq" OWNED BY "public"."ingredients"."id";



CREATE TABLE IF NOT EXISTS "public"."intakes" (
    "id" bigint NOT NULL,
    "user_id" bigint NOT NULL,
    "dish_id" bigint NOT NULL,
    "intake_time" timestamp with time zone NOT NULL,
    "portion_size" numeric(5,2) DEFAULT 1.0,
    "water_ml" integer,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "public"."intakes" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."intakes_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."intakes_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."intakes_id_seq" OWNED BY "public"."intakes"."id";



CREATE TABLE IF NOT EXISTS "public"."llm_models" (
    "id" bigint NOT NULL,
    "model_name" character varying(100) NOT NULL,
    "provider_name" character varying(100) NOT NULL,
    "model_nickname" character varying(100),
    "cost_per_million_input_tokens" numeric(10,4) NOT NULL,
    "cost_per_million_output_tokens" numeric(10,4) NOT NULL,
    "is_available" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE "public"."llm_models" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."llm_models_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."llm_models_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."llm_models_id_seq" OWNED BY "public"."llm_models"."id";



CREATE TABLE IF NOT EXISTS "public"."menu_dishes" (
    "id" bigint NOT NULL,
    "menu_id" bigint NOT NULL,
    "dish_id" bigint NOT NULL
);


ALTER TABLE "public"."menu_dishes" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."menu_dishes_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."menu_dishes_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."menu_dishes_id_seq" OWNED BY "public"."menu_dishes"."id";



CREATE TABLE IF NOT EXISTS "public"."menus" (
    "id" bigint NOT NULL,
    "user_id" bigint NOT NULL,
    "name" character varying(100) NOT NULL,
    "occasion" character varying(100),
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "public"."menus" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."menus_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."menus_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."menus_id_seq" OWNED BY "public"."menus"."id";



CREATE TABLE IF NOT EXISTS "public"."messages" (
    "id" bigint NOT NULL,
    "conversation_id" bigint NOT NULL,
    "user_id" bigint NOT NULL,
    "content" "text" NOT NULL,
    "is_user_message" boolean NOT NULL,
    "llm_model_id" bigint,
    "input_tokens" integer,
    "output_tokens" integer,
    "parent_message_id" bigint,
    "message_type" character varying(50) DEFAULT 'text'::character varying NOT NULL,
    "attachments" "jsonb",
    "reactions" "jsonb",
    "status" character varying(50) DEFAULT 'sent'::character varying NOT NULL,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "extra_data" "jsonb",
    CONSTRAINT "valid_message_type" CHECK ((("message_type")::"text" = ANY (ARRAY[('text'::character varying)::"text", ('image'::character varying)::"text", ('file'::character varying)::"text", ('system'::character varying)::"text"]))),
    CONSTRAINT "valid_status" CHECK ((("status")::"text" = ANY (ARRAY[('sent'::character varying)::"text", ('delivered'::character varying)::"text", ('read'::character varying)::"text", ('edited'::character varying)::"text", ('deleted'::character varying)::"text"])))
);


ALTER TABLE "public"."messages" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."messages_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."messages_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."messages_id_seq" OWNED BY "public"."messages"."id";



CREATE TABLE IF NOT EXISTS "public"."otps" (
    "id" integer NOT NULL,
    "user_id" integer NOT NULL,
    "email" character varying NOT NULL,
    "code" character varying NOT NULL,
    "purpose" character varying NOT NULL,
    "is_used" boolean,
    "expires_at" timestamp without time zone NOT NULL,
    "created_at" timestamp without time zone
);


ALTER TABLE "public"."otps" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."otps_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."otps_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."otps_id_seq" OWNED BY "public"."otps"."id";



CREATE TABLE IF NOT EXISTS "public"."password_reset_requests" (
    "id" integer NOT NULL,
    "user_id" integer NOT NULL,
    "request_id" character varying NOT NULL,
    "is_used" boolean,
    "expires_at" timestamp without time zone NOT NULL,
    "created_at" timestamp without time zone
);


ALTER TABLE "public"."password_reset_requests" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."password_reset_requests_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."password_reset_requests_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."password_reset_requests_id_seq" OWNED BY "public"."password_reset_requests"."id";



CREATE TABLE IF NOT EXISTS "public"."posts" (
    "id" bigint NOT NULL,
    "user_id" bigint NOT NULL,
    "title" character varying(255) NOT NULL,
    "content" "text" NOT NULL,
    "dish_id" bigint,
    "tags" "text"[],
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "public"."posts" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."posts_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."posts_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."posts_id_seq" OWNED BY "public"."posts"."id";



CREATE TABLE IF NOT EXISTS "public"."refresh_tokens" (
    "id" integer NOT NULL,
    "token" character varying NOT NULL,
    "user_id" integer NOT NULL,
    "expires_at" timestamp without time zone NOT NULL,
    "is_revoked" boolean,
    "created_at" timestamp without time zone
);


ALTER TABLE "public"."refresh_tokens" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."refresh_tokens_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."refresh_tokens_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."refresh_tokens_id_seq" OWNED BY "public"."refresh_tokens"."id";



CREATE TABLE IF NOT EXISTS "public"."user_profiles" (
    "user_id" integer NOT NULL,
    "first_name" character varying(50),
    "last_name" character varying(50),
    "gender" character varying(20) NOT NULL,
    "date_of_birth" "date" NOT NULL,
    "location_city" character varying(100),
    "location_country" character varying(100),
    "latitude" numeric(9,6),
    "longitude" numeric(9,6),
    "profile_image_url" character varying(255),
    "bio" "text",
    "dietary_restrictions" "text"[],
    "allergies" "text"[],
    "medical_conditions" "text"[],
    "fitness_goals" "text"[],
    "taste_preferences" "text"[],
    "cuisine_interests" "text"[],
    "cooking_skill_level" character varying(20) DEFAULT 'beginner'::character varying,
    "email_notifications_enabled" boolean DEFAULT true,
    "push_notifications_enabled" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "height_cm" numeric(6,2) NOT NULL,
    "weight_kg" numeric(6,2) NOT NULL
);


ALTER TABLE "public"."user_profiles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."users" (
    "id" integer NOT NULL,
    "email" character varying NOT NULL,
    "username" character varying NOT NULL,
    "full_name" character varying,
    "hashed_password" character varying,
    "is_active" boolean,
    "is_verified" boolean,
    "is_superuser" boolean,
    "oauth_provider" character varying,
    "oauth_id" character varying,
    "created_at" timestamp without time zone,
    "updated_at" timestamp without time zone,
    "last_login_at" timestamp without time zone
);


ALTER TABLE "public"."users" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."users_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."users_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."users_id_seq" OWNED BY "public"."users"."id";



ALTER TABLE ONLY "public"."comments" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."comments_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."conversations" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."conversations_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."dish_ingredients" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."dish_ingredients_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."dishes" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."dishes_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."fitness_plans" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."fitness_plans_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."health_history" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."health_history_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."ingredients" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."ingredients_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."intakes" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."intakes_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."llm_models" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."llm_models_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."menu_dishes" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."menu_dishes_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."menus" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."menus_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."messages" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."messages_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."otps" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."otps_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."password_reset_requests" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."password_reset_requests_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."posts" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."posts_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."refresh_tokens" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."refresh_tokens_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."users" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."users_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."alembic_version"
    ADD CONSTRAINT "alembic_version_pkc" PRIMARY KEY ("version_num");



ALTER TABLE ONLY "public"."comments"
    ADD CONSTRAINT "comments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."conversations"
    ADD CONSTRAINT "conversations_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."dish_ingredients"
    ADD CONSTRAINT "dish_ingredients_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."dishes"
    ADD CONSTRAINT "dishes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."fitness_plans"
    ADD CONSTRAINT "fitness_plans_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."health_history"
    ADD CONSTRAINT "health_history_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."ingredients"
    ADD CONSTRAINT "ingredients_name_key" UNIQUE ("name");



ALTER TABLE ONLY "public"."ingredients"
    ADD CONSTRAINT "ingredients_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."intakes"
    ADD CONSTRAINT "intakes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."llm_models"
    ADD CONSTRAINT "llm_models_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."menu_dishes"
    ADD CONSTRAINT "menu_dishes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."menus"
    ADD CONSTRAINT "menus_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."otps"
    ADD CONSTRAINT "otps_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."password_reset_requests"
    ADD CONSTRAINT "password_reset_requests_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."password_reset_requests"
    ADD CONSTRAINT "password_reset_requests_request_id_key" UNIQUE ("request_id");



ALTER TABLE ONLY "public"."posts"
    ADD CONSTRAINT "posts_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."refresh_tokens"
    ADD CONSTRAINT "refresh_tokens_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."refresh_tokens"
    ADD CONSTRAINT "refresh_tokens_token_key" UNIQUE ("token");



ALTER TABLE ONLY "public"."dish_ingredients"
    ADD CONSTRAINT "uix_dish_ingredient" UNIQUE ("dish_id", "ingredient_id");



ALTER TABLE ONLY "public"."menu_dishes"
    ADD CONSTRAINT "uix_menu_dish" UNIQUE ("menu_id", "dish_id");



ALTER TABLE ONLY "public"."llm_models"
    ADD CONSTRAINT "uix_model_provider" UNIQUE ("model_name", "provider_name");



ALTER TABLE ONLY "public"."user_profiles"
    ADD CONSTRAINT "user_profiles_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_username_key" UNIQUE ("username");



CREATE INDEX "ix_llm_models_id" ON "public"."llm_models" USING "btree" ("id");



CREATE INDEX "ix_otps_email" ON "public"."otps" USING "btree" ("email");



CREATE INDEX "ix_otps_id" ON "public"."otps" USING "btree" ("id");



CREATE INDEX "ix_password_reset_requests_id" ON "public"."password_reset_requests" USING "btree" ("id");



CREATE UNIQUE INDEX "ix_password_reset_requests_request_id" ON "public"."password_reset_requests" USING "btree" ("request_id");



CREATE INDEX "ix_refresh_tokens_id" ON "public"."refresh_tokens" USING "btree" ("id");



CREATE UNIQUE INDEX "ix_refresh_tokens_token" ON "public"."refresh_tokens" USING "btree" ("token");



CREATE UNIQUE INDEX "ix_users_email" ON "public"."users" USING "btree" ("email");



CREATE INDEX "ix_users_id" ON "public"."users" USING "btree" ("id");



CREATE UNIQUE INDEX "ix_users_username" ON "public"."users" USING "btree" ("username");



CREATE OR REPLACE TRIGGER "profile_health_update_trigger" BEFORE UPDATE ON "public"."user_profiles" FOR EACH ROW EXECUTE FUNCTION "public"."log_profile_health_changes"();



ALTER TABLE ONLY "public"."comments"
    ADD CONSTRAINT "comments_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "public"."posts"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."comments"
    ADD CONSTRAINT "comments_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."conversations"
    ADD CONSTRAINT "conversations_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."dish_ingredients"
    ADD CONSTRAINT "dish_ingredients_dish_id_fkey" FOREIGN KEY ("dish_id") REFERENCES "public"."dishes"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."dish_ingredients"
    ADD CONSTRAINT "dish_ingredients_ingredient_id_fkey" FOREIGN KEY ("ingredient_id") REFERENCES "public"."ingredients"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."dishes"
    ADD CONSTRAINT "dishes_created_by_user_id_fkey" FOREIGN KEY ("created_by_user_id") REFERENCES "public"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."fitness_plans"
    ADD CONSTRAINT "fitness_plans_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."health_history"
    ADD CONSTRAINT "fk_user_profile" FOREIGN KEY ("user_id") REFERENCES "public"."user_profiles"("user_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."intakes"
    ADD CONSTRAINT "intakes_dish_id_fkey" FOREIGN KEY ("dish_id") REFERENCES "public"."dishes"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."intakes"
    ADD CONSTRAINT "intakes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."menu_dishes"
    ADD CONSTRAINT "menu_dishes_dish_id_fkey" FOREIGN KEY ("dish_id") REFERENCES "public"."dishes"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."menu_dishes"
    ADD CONSTRAINT "menu_dishes_menu_id_fkey" FOREIGN KEY ("menu_id") REFERENCES "public"."menus"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."menus"
    ADD CONSTRAINT "menus_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_conversation_id_fkey" FOREIGN KEY ("conversation_id") REFERENCES "public"."conversations"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_llm_model_id_fkey" FOREIGN KEY ("llm_model_id") REFERENCES "public"."llm_models"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_parent_message_id_fkey" FOREIGN KEY ("parent_message_id") REFERENCES "public"."messages"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."otps"
    ADD CONSTRAINT "otps_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."password_reset_requests"
    ADD CONSTRAINT "password_reset_requests_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."posts"
    ADD CONSTRAINT "posts_dish_id_fkey" FOREIGN KEY ("dish_id") REFERENCES "public"."dishes"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."posts"
    ADD CONSTRAINT "posts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."refresh_tokens"
    ADD CONSTRAINT "refresh_tokens_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."user_profiles"
    ADD CONSTRAINT "user_profiles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



CREATE POLICY "Enable insert for authenticated users only" ON "public"."refresh_tokens" FOR INSERT WITH CHECK (true);



CREATE POLICY "Enable insert for users based on user_id" ON "public"."users" FOR INSERT WITH CHECK (true);



CREATE POLICY "Enable read access for all users" ON "public"."refresh_tokens" FOR SELECT USING (true);



CREATE POLICY "Enable update for users based on email" ON "public"."users" FOR UPDATE USING (((( SELECT "auth"."jwt"() AS "jwt") ->> 'email'::"text") = ("email")::"text")) WITH CHECK (((( SELECT "auth"."jwt"() AS "jwt") ->> 'email'::"text") = ("email")::"text"));



ALTER TABLE "public"."alembic_version" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."otps" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."password_reset_requests" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."refresh_tokens" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "select" ON "public"."users" FOR SELECT USING (true);



ALTER TABLE "public"."users" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."ingredients";



GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";











































































































































































GRANT ALL ON FUNCTION "public"."log_profile_health_changes"() TO "anon";
GRANT ALL ON FUNCTION "public"."log_profile_health_changes"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."log_profile_health_changes"() TO "service_role";


















GRANT ALL ON TABLE "public"."alembic_version" TO "anon";
GRANT ALL ON TABLE "public"."alembic_version" TO "authenticated";
GRANT ALL ON TABLE "public"."alembic_version" TO "service_role";



GRANT ALL ON TABLE "public"."comments" TO "anon";
GRANT ALL ON TABLE "public"."comments" TO "authenticated";
GRANT ALL ON TABLE "public"."comments" TO "service_role";



GRANT ALL ON SEQUENCE "public"."comments_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."comments_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."comments_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."conversations" TO "anon";
GRANT ALL ON TABLE "public"."conversations" TO "authenticated";
GRANT ALL ON TABLE "public"."conversations" TO "service_role";



GRANT ALL ON SEQUENCE "public"."conversations_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."conversations_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."conversations_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."dish_ingredients" TO "anon";
GRANT ALL ON TABLE "public"."dish_ingredients" TO "authenticated";
GRANT ALL ON TABLE "public"."dish_ingredients" TO "service_role";



GRANT ALL ON SEQUENCE "public"."dish_ingredients_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."dish_ingredients_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."dish_ingredients_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."dishes" TO "anon";
GRANT ALL ON TABLE "public"."dishes" TO "authenticated";
GRANT ALL ON TABLE "public"."dishes" TO "service_role";



GRANT ALL ON SEQUENCE "public"."dishes_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."dishes_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."dishes_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."fitness_plans" TO "anon";
GRANT ALL ON TABLE "public"."fitness_plans" TO "authenticated";
GRANT ALL ON TABLE "public"."fitness_plans" TO "service_role";



GRANT ALL ON SEQUENCE "public"."fitness_plans_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."fitness_plans_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."fitness_plans_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."health_history" TO "anon";
GRANT ALL ON TABLE "public"."health_history" TO "authenticated";
GRANT ALL ON TABLE "public"."health_history" TO "service_role";



GRANT ALL ON SEQUENCE "public"."health_history_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."health_history_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."health_history_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."ingredients" TO "anon";
GRANT ALL ON TABLE "public"."ingredients" TO "authenticated";
GRANT ALL ON TABLE "public"."ingredients" TO "service_role";



GRANT ALL ON SEQUENCE "public"."ingredients_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."ingredients_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."ingredients_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."intakes" TO "anon";
GRANT ALL ON TABLE "public"."intakes" TO "authenticated";
GRANT ALL ON TABLE "public"."intakes" TO "service_role";



GRANT ALL ON SEQUENCE "public"."intakes_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."intakes_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."intakes_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."llm_models" TO "anon";
GRANT ALL ON TABLE "public"."llm_models" TO "authenticated";
GRANT ALL ON TABLE "public"."llm_models" TO "service_role";



GRANT ALL ON SEQUENCE "public"."llm_models_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."llm_models_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."llm_models_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."menu_dishes" TO "anon";
GRANT ALL ON TABLE "public"."menu_dishes" TO "authenticated";
GRANT ALL ON TABLE "public"."menu_dishes" TO "service_role";



GRANT ALL ON SEQUENCE "public"."menu_dishes_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."menu_dishes_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."menu_dishes_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."menus" TO "anon";
GRANT ALL ON TABLE "public"."menus" TO "authenticated";
GRANT ALL ON TABLE "public"."menus" TO "service_role";



GRANT ALL ON SEQUENCE "public"."menus_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."menus_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."menus_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."messages" TO "anon";
GRANT ALL ON TABLE "public"."messages" TO "authenticated";
GRANT ALL ON TABLE "public"."messages" TO "service_role";



GRANT ALL ON SEQUENCE "public"."messages_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."messages_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."messages_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."otps" TO "anon";
GRANT ALL ON TABLE "public"."otps" TO "authenticated";
GRANT ALL ON TABLE "public"."otps" TO "service_role";



GRANT ALL ON SEQUENCE "public"."otps_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."otps_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."otps_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."password_reset_requests" TO "anon";
GRANT ALL ON TABLE "public"."password_reset_requests" TO "authenticated";
GRANT ALL ON TABLE "public"."password_reset_requests" TO "service_role";



GRANT ALL ON SEQUENCE "public"."password_reset_requests_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."password_reset_requests_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."password_reset_requests_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."posts" TO "anon";
GRANT ALL ON TABLE "public"."posts" TO "authenticated";
GRANT ALL ON TABLE "public"."posts" TO "service_role";



GRANT ALL ON SEQUENCE "public"."posts_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."posts_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."posts_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."refresh_tokens" TO "anon";
GRANT ALL ON TABLE "public"."refresh_tokens" TO "authenticated";
GRANT ALL ON TABLE "public"."refresh_tokens" TO "service_role";



GRANT ALL ON SEQUENCE "public"."refresh_tokens_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."refresh_tokens_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."refresh_tokens_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."user_profiles" TO "anon";
GRANT ALL ON TABLE "public"."user_profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."user_profiles" TO "service_role";



GRANT ALL ON TABLE "public"."users" TO "anon";
GRANT ALL ON TABLE "public"."users" TO "authenticated";
GRANT ALL ON TABLE "public"."users" TO "service_role";



GRANT ALL ON SEQUENCE "public"."users_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."users_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."users_id_seq" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";






























RESET ALL;
