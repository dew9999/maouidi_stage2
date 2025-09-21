

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


CREATE EXTENSION IF NOT EXISTS "pg_cron" WITH SCHEMA "pg_catalog";






CREATE EXTENSION IF NOT EXISTS "pg_net" WITH SCHEMA "extensions";






COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."partner_category" AS ENUM (
    'Doctors',
    'Clinics',
    'Homecare',
    'Charities'
);


ALTER TYPE "public"."partner_category" OWNER TO "postgres";


CREATE TYPE "public"."specialty_enum" AS ENUM (
    'Anatomy and Pathological Cytology',
    'Cardiology',
    'Dermatology and Venereology',
    'Endocrinology and Diabetology',
    'Epidemiology and Preventive Medicine',
    'Gastroenterology and Hepatology',
    'Hematology (Clinical)',
    'Infectious Diseases',
    'Internal Medicine',
    'Medical Oncology',
    'Nephrology',
    'Neurology',
    'Nuclear Medicine',
    'Pediatrics',
    'Physical Medicine and Rehabilitation',
    'Pneumology',
    'Psychiatry',
    'Radiology / Medical Imaging',
    'Radiotherapy',
    'Rheumatology',
    'Sports Medicine',
    'Anesthesiology and Reanimation',
    'Cardiovascular Surgery',
    'General Surgery',
    'Maxillofacial Surgery',
    'Neurosurgery',
    'Obstetrics and Gynecology',
    'Ophthalmology',
    'Orthopedics and Traumatology',
    'Otorhinolaryngology (ENT)',
    'Pediatric Surgery',
    'Plastic, Reconstructive, and Aesthetic Surgery',
    'Thoracic Surgery',
    'Urology',
    'Vascular Surgery',
    'Biochemistry',
    'Clinical Neurophysiology',
    'Hematology (Biological)',
    'Histology, Embryology, and Cytogenetics',
    'Immunology',
    'Microbiology',
    'Medical Biophysics',
    'Parasitology and Mycology',
    'Pharmacology',
    'Physiology',
    'Toxicology',
    'Child Psychiatry',
    'Community Health / Public Health',
    'Emergency Medicine',
    'Forensic Medicine and Medical Deontology',
    'Occupational Medicine',
    'Stomatology',
    'Transfusion Medicine (Hemobiology)'
);


ALTER TYPE "public"."specialty_enum" OWNER TO "postgres";


CREATE TYPE "public"."user_role_enum" AS ENUM (
    'Patient',
    'Medical Partner'
);


ALTER TYPE "public"."user_role_enum" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."book_appointment"("partner_id_arg" "uuid", "appointment_time_arg" timestamp with time zone, "on_behalf_of_name_arg" "text", "on_behalf_of_phone_arg" "text", "is_partner_override" boolean, "case_description_arg" "text", "patient_location_arg" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
DECLARE
  booking_user_id_arg UUID := auth.uid();
  partner_data RECORD;
  has_existing_appointment BOOLEAN;
  new_appointment_number INT;
  new_appointment_status TEXT;
BEGIN
  SELECT category, confirmation_mode, booking_system_type, daily_booking_limit
  INTO partner_data
  FROM public.medical_partners WHERE id = partner_id_arg;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Medical partner not found.';
  END IF;
  IF partner_data.category = 'Homecare' THEN
    new_appointment_status := 'Pending';
  ELSE
    IF partner_data.confirmation_mode = 'auto' THEN
      new_appointment_status := 'Confirmed';
    ELSE
      new_appointment_status := 'Pending';
    END IF;
  END IF;
  IF NOT is_partner_override THEN
    IF partner_data.booking_system_type = 'number_based' THEN
      SELECT EXISTS (
        SELECT 1 FROM public.appointments
        WHERE
          booking_user_id = booking_user_id_arg AND
          partner_id = partner_id_arg AND
          DATE(appointment_time) = DATE(appointment_time_arg) AND
          status NOT IN ('Cancelled_ByUser', 'Cancelled_ByPartner')
      ) INTO has_existing_appointment;
      IF has_existing_appointment THEN
        RAISE EXCEPTION 'You already have an appointment with this partner for today.';
      END IF;
    ELSE
      SELECT EXISTS (
        SELECT 1 FROM public.appointments
        WHERE
          booking_user_id = booking_user_id_arg AND
          partner_id = partner_id_arg AND
          DATE(appointment_time) = DATE(appointment_time_arg) AND
          status NOT IN ('Cancelled_ByUser', 'Cancelled_ByPartner', 'Completed')
      ) INTO has_existing_appointment;
      IF has_existing_appointment THEN
        RAISE EXCEPTION 'You already have an appointment with this partner on this day.';
      END IF;
    END IF;
  END IF;
  IF partner_data.booking_system_type = 'time_based' THEN
    INSERT INTO public.appointments (partner_id, booking_user_id, appointment_time, on_behalf_of_patient_name, on_behalf_of_patient_phone, status, case_description, patient_location)
    VALUES (partner_id_arg, booking_user_id_arg, appointment_time_arg, on_behalf_of_name_arg, on_behalf_of_phone_arg, new_appointment_status, case_description_arg, patient_location_arg);
  ELSIF partner_data.booking_system_type = 'number_based' THEN
    SELECT COALESCE(MAX(appointment_number), 0) + 1
    INTO new_appointment_number
    FROM public.appointments
    WHERE
      partner_id = partner_id_arg AND
      DATE(appointment_time AT TIME ZONE 'utc') = DATE(appointment_time_arg AT TIME ZONE 'utc') AND
      status NOT IN ('Cancelled_ByUser', 'Cancelled_ByPartner');
    IF new_appointment_number > partner_data.daily_booking_limit THEN
      RAISE EXCEPTION 'This partner is fully booked on this day.';
    END IF;
    INSERT INTO public.appointments (partner_id, booking_user_id, appointment_time, on_behalf_of_patient_name, on_behalf_of_patient_phone, status, appointment_number, case_description, patient_location)
    VALUES (partner_id_arg, booking_user_id_arg, appointment_time_arg, on_behalf_of_name_arg, on_behalf_of_phone_arg, new_appointment_status, new_appointment_number, case_description_arg, patient_location_arg);
  END IF;
END;
$$;


ALTER FUNCTION "public"."book_appointment"("partner_id_arg" "uuid", "appointment_time_arg" timestamp with time zone, "on_behalf_of_name_arg" "text", "on_behalf_of_phone_arg" "text", "is_partner_override" boolean, "case_description_arg" "text", "patient_location_arg" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."cancel_and_reorder_queue"("appointment_id_arg" bigint) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
DECLARE
  canceled_app_partner_id UUID;
  canceled_app_number INT;
  canceled_app_date DATE;
  current_user_id UUID := auth.uid();
BEGIN
  SELECT partner_id, appointment_number, DATE(appointment_time)
  INTO canceled_app_partner_id, canceled_app_number, canceled_app_date
  FROM public.appointments
  WHERE id = appointment_id_arg AND booking_user_id = current_user_id;
  IF NOT FOUND OR canceled_app_number IS NULL THEN
    UPDATE public.appointments
    SET status = 'Cancelled_ByUser'
    WHERE id = appointment_id_arg AND booking_user_id = current_user_id;
    RETURN;
  END IF;
  UPDATE public.appointments
  SET status = 'Cancelled_ByUser'
  WHERE id = appointment_id_arg;
  UPDATE public.appointments
  SET appointment_number = appointment_number - 1
  WHERE
    partner_id = canceled_app_partner_id
    AND DATE(appointment_time) = canceled_app_date
    AND appointment_number > canceled_app_number;
END;
$$;


ALTER FUNCTION "public"."cancel_and_reorder_queue"("appointment_id_arg" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."close_day_and_cancel_appointments"("closed_day_arg" "date") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
DECLARE
  partner_id_arg UUID := auth.uid();
  partner_name_text TEXT;
  affected_appointment RECORD;
BEGIN
  SELECT full_name INTO partner_name_text FROM public.medical_partners WHERE id = partner_id_arg;
  FOR affected_appointment IN
    SELECT id, booking_user_id, appointment_time
    FROM public.appointments
    WHERE partner_id = partner_id_arg
      AND status IN ('Pending', 'Confirmed')
      AND appointment_time::date = closed_day_arg
  LOOP
    PERFORM net.http_post(
      url:='https://jtoeizfokgydtsqdciuu.supabase.co/functions/v1/send-notification',
      headers:=jsonb_build_object('Content-Type', 'application/json','Authorization', 'Bearer ' || current_setting('request.jwt.claim.raw', true)),
      body:=jsonb_build_object(
        'recipient_user_id', affected_appointment.booking_user_id,
        'title', 'Appointment Canceled',
        'body', 'Your appointment on ' || to_char(affected_appointment.appointment_time, 'Mon DD') || ' with ' || partner_name_text || ' has been canceled as the provider will be closed that day.'
      )
    );
    UPDATE public.appointments
    SET status = 'Cancelled_ByPartner'
    WHERE id = affected_appointment.id;
  END LOOP;
END;
$$;


ALTER FUNCTION "public"."close_day_and_cancel_appointments"("closed_day_arg" "date") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."delete_user_account"() RETURNS "void"
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
  DELETE FROM auth.users WHERE id = auth.uid();
$$;


ALTER FUNCTION "public"."delete_user_account"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_clinic_appointments"("clinic_id_arg" "uuid", "doctor_id_arg" "uuid") RETURNS TABLE("id" bigint, "appointment_time" timestamp with time zone, "status" "text", "appointment_number" integer, "doctor_name" "text", "patient_name" "text", "case_description" "text", "patient_location" "text")
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    a.id,
    a.appointment_time,
    a.status,
    a.appointment_number,
    mp.full_name AS doctor_name,
    COALESCE(a.on_behalf_of_patient_name, u.first_name || ' ' || u.last_name, 'A Patient') AS patient_name,
    a.case_description,
    a.patient_location
  FROM
    public.appointments AS a
  JOIN
    public.medical_partners AS mp ON a.partner_id = mp.id
  LEFT JOIN
    public.users AS u ON a.booking_user_id = u.id
  WHERE
    mp.parent_clinic_id = clinic_id_arg
    AND (doctor_id_arg IS NULL OR a.partner_id = doctor_id_arg)
  ORDER BY
    a.appointment_time DESC;
END;
$$;


ALTER FUNCTION "public"."get_clinic_appointments"("clinic_id_arg" "uuid", "doctor_id_arg" "uuid") OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."medical_partners" (
    "id" "uuid" NOT NULL,
    "full_name" "text",
    "specialty" "public"."specialty_enum",
    "confirmation_mode" "text" DEFAULT 'auto'::"text" NOT NULL,
    "working_hours" "jsonb",
    "closed_days" "date"[],
    "appointment_dur" integer,
    "average_rating" numeric(2,1) DEFAULT 0.0,
    "review_count" integer DEFAULT 0,
    "is_verified" boolean DEFAULT false,
    "is_featured" boolean DEFAULT false,
    "photo_url" "text",
    "category" "public"."partner_category",
    "address" "text",
    "national_id_number" "text",
    "medical_license_number" "text",
    "bio" "text",
    "location_url" "text",
    "booking_system_type" "text" DEFAULT 'time_based'::"text" NOT NULL,
    "daily_booking_limit" integer DEFAULT 20,
    "is_active" boolean DEFAULT true,
    "parent_clinic_id" "uuid",
    "notifications_enabled" boolean DEFAULT true,
    "onesignal_player_id" "text"
);


ALTER TABLE "public"."medical_partners" OWNER TO "postgres";


COMMENT ON TABLE "public"."medical_partners" IS 'Stores profiles for all medical partners.';



CREATE OR REPLACE FUNCTION "public"."get_filtered_partners"("category_arg" "text", "state_arg" "text", "specialty_arg" "text") RETURNS SETOF "public"."medical_partners"
    LANGUAGE "sql"
    SET "search_path" TO ''
    AS $$
  SELECT mp.*
  FROM public.medical_partners AS mp
  LEFT JOIN public.users AS u ON mp.id = u.id
  WHERE
    mp.is_verified = true AND
    mp.category::text = category_arg AND
    (state_arg IS NULL OR u.state = state_arg) AND
    (specialty_arg IS NULL OR mp.specialty = specialty_arg::public.specialty_enum);
$$;


ALTER FUNCTION "public"."get_filtered_partners"("category_arg" "text", "state_arg" "text", "specialty_arg" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_reviews_with_user_names"("partner_id_arg" "uuid") RETURNS TABLE("rating" numeric, "review_text" "text", "created_at" timestamp with time zone, "first_name" "text", "gender" "text")
    LANGUAGE "sql"
    SET "search_path" TO ''
    AS $$
  SELECT
    r.rating,
    r.review_text,
    r.created_at,
    u.first_name,
    u.gender
  FROM
    public.reviews AS r
  JOIN
    public.users AS u ON r.user_id = u.id
  WHERE
    r.partner_id = partner_id_arg
  ORDER BY
    r.created_at DESC;
$$;


ALTER FUNCTION "public"."get_reviews_with_user_names"("partner_id_arg" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_weekly_appointment_stats"("partner_id_arg" "uuid") RETURNS TABLE("day_of_week" "text", "appointment_count" bigint)
    LANGUAGE "sql"
    SET "search_path" TO ''
    AS $$
  WITH last_7_days AS (
    SELECT generate_series(
      CURRENT_DATE - INTERVAL '6 days',
      CURRENT_DATE,
      '1 day'
    )::date AS day
  )
  SELECT
    to_char(d.day, 'Dy') AS day_of_week,
    COUNT(a.id) AS appointment_count
  FROM last_7_days d
  LEFT JOIN public.appointments a ON DATE(a.appointment_time AT TIME ZONE 'utc') = d.day
    AND a.partner_id = partner_id_arg
    AND a.status = 'Completed'
  GROUP BY d.day
  ORDER BY d.day;
$$;


ALTER FUNCTION "public"."get_weekly_appointment_stats"("partner_id_arg" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_appointment_notification"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
DECLARE
  partner_name TEXT;
  patient_name TEXT;
  recipient_id UUID;
  notification_title TEXT;
  notification_body TEXT;
BEGIN
  SELECT full_name INTO partner_name FROM public.medical_partners WHERE id = NEW.partner_id;
  SELECT COALESCE(NEW.on_behalf_of_patient_name, u.first_name || ' ' || u.last_name, 'A patient')
  INTO patient_name
  FROM public.users u WHERE u.id = NEW.booking_user_id;
  IF TG_OP = 'INSERT' THEN
    recipient_id := NEW.partner_id;
    notification_title := 'New Booking';
    notification_body := patient_name || ' has requested an appointment.';
  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.status <> NEW.status THEN
      IF OLD.status = 'Pending' AND NEW.status = 'Confirmed' THEN
        recipient_id := NEW.booking_user_id;
        notification_title := 'Appointment Confirmed!';
        notification_body := 'Your appointment with ' || partner_name || ' on ' || to_char(NEW.appointment_time, 'Mon DD at HH24:MI') || ' is confirmed.';
      END IF;
      IF OLD.status = 'Pending' AND NEW.status = 'Cancelled_ByPartner' THEN
        recipient_id := NEW.booking_user_id;
        notification_title := 'Appointment Declined';
        notification_body := 'Unfortunately, ' || partner_name || ' was unable to accept your appointment request.';
      END IF;
      IF OLD.status = 'Confirmed' AND NEW.status = 'Cancelled_ByPartner' THEN
        recipient_id := NEW.booking_user_id;
        notification_title := 'Appointment Canceled';
        notification_body := 'Unfortunately, your upcoming appointment with ' || partner_name || ' has been canceled.';
      END IF;
      IF NEW.status = 'Cancelled_ByUser' THEN
        recipient_id := NEW.partner_id;
        notification_title := 'Booking Canceled';
        notification_body := patient_name || ' has canceled their appointment for ' || to_char(NEW.appointment_time, 'Mon DD at HH24:MI') || '.';
      END IF;
    END IF;
  END IF;
  IF recipient_id IS NOT NULL THEN
    PERFORM net.http_post(
        url:='https://jtoeizfokgydtsqdciuu.supabase.co/functions/v1/send-notification',
        headers:=jsonb_build_object('Content-Type', 'application/json','Authorization', 'Bearer ' || current_setting('request.jwt.claim.raw', true)),
        body:=jsonb_build_object(
            'recipient_user_id', recipient_id,
            'title', notification_title,
            'body', notification_body
        )
    );
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_appointment_notification"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_partner_emergency"() RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
DECLARE
  partner_settings RECORD;
  affected_appointment RECORD;
BEGIN
  SELECT id, booking_system_type INTO partner_settings
  FROM public.medical_partners
  WHERE id = auth.uid();
  IF partner_settings.booking_system_type = 'time_based' THEN
    FOR affected_appointment IN
      SELECT id, booking_user_id FROM public.appointments
      WHERE partner_id = partner_settings.id
        AND status = 'Confirmed'
        AND appointment_time BETWEEN now() AND now() + interval '30 minutes'
    LOOP
      PERFORM net.http_post(
        url:='https://jtoeizfokgydtsqdciuu.supabase.co/functions/v1/send-notification',
        headers:=jsonb_build_object('Content-Type', 'application/json','Authorization', 'Bearer ' || current_setting('request.jwt.claim.raw', true)),
        body:=jsonb_build_object(
          'recipient_user_id', affected_appointment.booking_user_id,
          'title', 'Urgent Alert',
          'body', 'Due to an emergency, your upcoming appointment with ' || (SELECT full_name FROM medical_partners WHERE id = partner_settings.id) || ' has been canceled. We apologize for the inconvenience.'
        )
      );
      UPDATE public.appointments SET status = 'Cancelled_ByPartner' WHERE id = affected_appointment.id;
    END LOOP;
  ELSIF partner_settings.booking_system_type = 'number_based' THEN
    FOR affected_appointment IN
      SELECT id, booking_user_id FROM public.appointments
      WHERE partner_id = partner_settings.id
        AND status IN ('Confirmed', 'Pending')
        AND appointment_time::date = current_date
      ORDER BY appointment_number ASC
      LIMIT 5
    LOOP
      PERFORM net.http_post(
        url:='https://jtoeizfokgydtsqdciuu.supabase.co/functions/v1/send-notification',
        headers:=jsonb_build_object('Content-Type', 'application/json','Authorization', 'Bearer ' || current_setting('request.jwt.claim.raw', true)),
        body:=jsonb_build_object(
          'recipient_user_id', affected_appointment.booking_user_id,
          'title', 'Urgent Alert',
          'body', 'Due to an emergency, all upcoming appointments with ' || (SELECT full_name FROM medical_partners WHERE id = partner_settings.id) || ' today have been canceled. We apologize for the inconvenience.'
        )
      );
      UPDATE public.appointments SET status = 'Cancelled_ByPartner' WHERE id = affected_appointment.id;
    END LOOP;
  END IF;
END;
$$;


ALTER FUNCTION "public"."handle_partner_emergency"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."reschedule_appointment_to_end_of_queue"("appointment_id_arg" bigint, "partner_id_arg" "uuid") RETURNS "void"
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
DECLARE
  current_num INT;
  max_num INT;
  appointment_date DATE;
BEGIN
  SELECT appointment_number, DATE(appointment_time)
  INTO current_num, appointment_date
  FROM public.appointments
  WHERE id = appointment_id_arg;
  IF NOT FOUND OR current_num IS NULL THEN
    RETURN;
  END IF;
  SELECT COALESCE(MAX(appointment_number), 0)
  INTO max_num
  FROM public.appointments
  WHERE
    partner_id = partner_id_arg
    AND DATE(appointment_time) = appointment_date
    AND status NOT IN ('Cancelled_ByUser', 'Cancelled_ByPartner');
  UPDATE public.appointments
  SET appointment_number = appointment_number - 1
  WHERE
    partner_id = partner_id_arg
    AND DATE(appointment_time) = appointment_date
    AND appointment_number > current_num;
  UPDATE public.appointments
  SET
    appointment_number = max_num,
    is_rescheduled = true
  WHERE id = appointment_id_arg;
END;
$$;


ALTER FUNCTION "public"."reschedule_appointment_to_end_of_queue"("appointment_id_arg" bigint, "partner_id_arg" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."search_partners"("search_term" "text") RETURNS SETOF "public"."medical_partners"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  -- We add a check to handle empty search terms
  IF search_term IS NULL OR search_term = '' THEN
    RETURN QUERY SELECT * FROM public.medical_partners WHERE is_verified = true LIMIT 20;
  ELSE
    RETURN QUERY
    SELECT *
    FROM public.medical_partners
    WHERE
      is_verified = true AND
      full_name ILIKE '%' || search_term || '%';
  END IF;
END;
$$;


ALTER FUNCTION "public"."search_partners"("search_term" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."send_appointment_reminders"() RETURNS "void"
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
DECLARE
  upcoming_appointment RECORD;
  partner_name TEXT;
BEGIN
  FOR upcoming_appointment IN
    SELECT a.id, a.booking_user_id, a.partner_id, a.appointment_time
    FROM public.appointments a
    WHERE a.status = 'Confirmed'
    AND (
      (a.appointment_time > now() + interval '23 hours' AND a.appointment_time < now() + interval '25 hours')
      OR
      (a.appointment_time > now() AND a.appointment_time < now() + interval '2 hours')
    )
  LOOP
    SELECT full_name INTO partner_name FROM public.medical_partners WHERE id = upcoming_appointment.partner_id;
    IF upcoming_appointment.appointment_time > now() + interval '23 hours' THEN
      PERFORM net.http_post(
        url:='https://jtoeizfokgydtsqdciuu.supabase.co/functions/v1/send-notification',
        headers:=jsonb_build_object('Content-Type', 'application/json','Authorization', 'Bearer ' || current_setting('request.jwt.claim.raw', true)),
        body:=jsonb_build_object(
          'recipient_user_id', upcoming_appointment.booking_user_id,
          'title', 'Appointment Reminder',
          'body', 'This is a reminder for your appointment with ' || partner_name || ' tomorrow at ' || to_char(upcoming_appointment.appointment_time, 'HH24:MI') || '.'
        )
      );
    ELSE
      PERFORM net.http_post(
        url:='https://jtoeizfokgydtsqdciuu.supabase.co/functions/v1/send-notification',
        headers:=jsonb_build_object('Content-Type', 'application/json','Authorization', 'Bearer ' || current_setting('request.jwt.claim.raw', true)),
        body:=jsonb_build_object(
          'recipient_user_id', upcoming_appointment.booking_user_id,
          'title', 'Appointment Soon',
          'body', 'Your appointment with ' || partner_name || ' is in one hour at ' || to_char(upcoming_appointment.appointment_time, 'HH24:MI') || '.'
        )
      );
    END IF;
  END LOOP;
END;
$$;


ALTER FUNCTION "public"."send_appointment_reminders"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."submit_review"("appointment_id_arg" bigint, "rating_arg" numeric, "review_text_arg" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
DECLARE
  target_appointment record;
BEGIN
  SELECT * INTO target_appointment
  FROM public.appointments
  WHERE id = appointment_id_arg AND booking_user_id = auth.uid();
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Appointment not found or you do not have permission to review it.';
  END IF;
  IF target_appointment.status <> 'Completed' THEN
    RAISE EXCEPTION 'You can only review completed appointments.';
  END IF;
  IF target_appointment.has_review = TRUE THEN
    RAISE EXCEPTION 'A review has already been submitted for this appointment.';
  END IF;
  IF target_appointment.completed_at IS NULL OR now() > target_appointment.completed_at + INTERVAL '2 hours' THEN
    RAISE EXCEPTION 'The 2-hour window to submit a review has passed.';
  END IF;
  INSERT INTO public.reviews(appointment_id, user_id, partner_id, rating, review_text)
  VALUES(appointment_id_arg, auth.uid(), target_appointment.partner_id, rating_arg, review_text_arg);
  UPDATE public.appointments
  SET has_review = TRUE
  WHERE id = appointment_id_arg;
END;
$$;


ALTER FUNCTION "public"."submit_review"("appointment_id_arg" bigint, "rating_arg" numeric, "review_text_arg" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_completed_appointments"() RETURNS "void"
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
BEGIN
  UPDATE public.appointments AS a
  SET
    status = 'Completed',
    completed_at = now()
  FROM
    public.medical_partners AS mp
  WHERE
    a.partner_id = mp.id AND
    a.status = 'Confirmed' AND
    a.appointment_number IS NULL AND
    (a.appointment_time + (mp.appointment_dur * INTERVAL '1 minute')) < now();
END;
$$;


ALTER FUNCTION "public"."update_completed_appointments"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_partner_rating_aggregates"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
BEGIN
  UPDATE public.medical_partners
  SET
    review_count = (
      SELECT COUNT(*)
      FROM public.reviews
      WHERE partner_id = NEW.partner_id
    ),
    average_rating = (
      SELECT AVG(rating)
      FROM public.reviews
      WHERE partner_id = NEW.partner_id
    )
  WHERE id = NEW.partner_id;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_partner_rating_aggregates"() OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."appointments" (
    "id" bigint NOT NULL,
    "partner_id" "uuid" NOT NULL,
    "booking_user_id" "uuid" NOT NULL,
    "on_behalf_of_patient_name" "text",
    "appointment_time" timestamp with time zone NOT NULL,
    "status" "text" DEFAULT 'Pending'::"text" NOT NULL,
    "on_behalf_of_patient_phone" "text",
    "appointment_number" integer,
    "is_rescheduled" boolean DEFAULT false,
    "completed_at" timestamp with time zone,
    "has_review" boolean DEFAULT false,
    "case_description" "text",
    "patient_location" "text"
);


ALTER TABLE "public"."appointments" OWNER TO "postgres";


COMMENT ON TABLE "public"."appointments" IS 'Manages all appointment bookings and their status.';



ALTER TABLE "public"."appointments" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."appointments_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."fcm_tokens" (
    "id" bigint NOT NULL,
    "user_id" "uuid" NOT NULL,
    "token" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."fcm_tokens" OWNER TO "postgres";


ALTER TABLE "public"."fcm_tokens" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."fcm_tokens_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."notifications" (
    "id" bigint NOT NULL,
    "user_id" "uuid" NOT NULL,
    "title" "text" NOT NULL,
    "body" "text" NOT NULL,
    "is_read" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."notifications" OWNER TO "postgres";


COMMENT ON TABLE "public"."notifications" IS 'Stores notifications for users.';



ALTER TABLE "public"."notifications" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."notifications_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."reviews" (
    "id" bigint NOT NULL,
    "partner_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "appointment_id" bigint NOT NULL,
    "rating" numeric(2,1) NOT NULL,
    "review_text" "text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."reviews" OWNER TO "postgres";


COMMENT ON TABLE "public"."reviews" IS 'Stores ratings and reviews for partners.';



ALTER TABLE "public"."reviews" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."reviews_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."users" (
    "id" "uuid" NOT NULL,
    "email" "text",
    "first_name" "text",
    "last_name" "text",
    "phone" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "role" "public"."user_role_enum" DEFAULT 'Patient'::"public"."user_role_enum",
    "state" "text",
    "date_of_birth" "date",
    "gender" "text",
    "onesignal_player_id" "text",
    "notifications_enabled" boolean DEFAULT true
);


ALTER TABLE "public"."users" OWNER TO "postgres";


COMMENT ON TABLE "public"."users" IS 'Stores user profile data. Links to auth.users.';



ALTER TABLE ONLY "public"."appointments"
    ADD CONSTRAINT "appointments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."fcm_tokens"
    ADD CONSTRAINT "fcm_tokens_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."fcm_tokens"
    ADD CONSTRAINT "fcm_tokens_user_id_token_key" UNIQUE ("user_id", "token");



ALTER TABLE ONLY "public"."medical_partners"
    ADD CONSTRAINT "medical_partners_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."reviews"
    ADD CONSTRAINT "reviews_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");



CREATE INDEX "idx_appointments_booking_user_id" ON "public"."appointments" USING "btree" ("booking_user_id");



CREATE INDEX "idx_appointments_status" ON "public"."appointments" USING "btree" ("status");



CREATE INDEX "idx_appointments_time" ON "public"."appointments" USING "btree" ("appointment_time");



CREATE INDEX "idx_notifications_user_id" ON "public"."notifications" USING "btree" ("user_id");



CREATE INDEX "idx_parent_clinic_id" ON "public"."medical_partners" USING "btree" ("parent_clinic_id");



CREATE INDEX "idx_reviews_appointment_id" ON "public"."reviews" USING "btree" ("appointment_id");



CREATE INDEX "idx_reviews_partner_id" ON "public"."reviews" USING "btree" ("partner_id");



CREATE INDEX "idx_reviews_user_id" ON "public"."reviews" USING "btree" ("user_id");



CREATE UNIQUE INDEX "unique_active_appointment_number_idx" ON "public"."appointments" USING "btree" ("partner_id", "appointment_number", ((("appointment_time" AT TIME ZONE 'utc'::"text"))::"date")) WHERE ("status" <> ALL (ARRAY['Cancelled_ByUser'::"text", 'Cancelled_ByPartner'::"text"]));



CREATE UNIQUE INDEX "unique_active_appointment_time" ON "public"."appointments" USING "btree" ("partner_id", "appointment_time") WHERE ("status" <> ALL (ARRAY['Cancelled_ByUser'::"text", 'Cancelled_ByPartner'::"text"]));



CREATE OR REPLACE TRIGGER "on_appointment_change" AFTER INSERT OR UPDATE ON "public"."appointments" FOR EACH ROW EXECUTE FUNCTION "public"."handle_appointment_notification"();



CREATE OR REPLACE TRIGGER "on_new_review_update_aggregates" AFTER INSERT ON "public"."reviews" FOR EACH ROW EXECUTE FUNCTION "public"."update_partner_rating_aggregates"();



ALTER TABLE ONLY "public"."appointments"
    ADD CONSTRAINT "appointments_booking_user_id_fkey" FOREIGN KEY ("booking_user_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."appointments"
    ADD CONSTRAINT "appointments_partner_id_fkey" FOREIGN KEY ("partner_id") REFERENCES "public"."medical_partners"("id");



ALTER TABLE ONLY "public"."fcm_tokens"
    ADD CONSTRAINT "fcm_tokens_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."medical_partners"
    ADD CONSTRAINT "medical_partners_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."medical_partners"
    ADD CONSTRAINT "medical_partners_parent_clinic_id_fkey" FOREIGN KEY ("parent_clinic_id") REFERENCES "public"."medical_partners"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."reviews"
    ADD CONSTRAINT "reviews_appointment_id_fkey" FOREIGN KEY ("appointment_id") REFERENCES "public"."appointments"("id");



ALTER TABLE ONLY "public"."reviews"
    ADD CONSTRAINT "reviews_partner_id_fkey" FOREIGN KEY ("partner_id") REFERENCES "public"."medical_partners"("id");



ALTER TABLE ONLY "public"."reviews"
    ADD CONSTRAINT "reviews_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



CREATE POLICY "Allow authenticated users to insert" ON "public"."reviews" FOR INSERT TO "authenticated" WITH CHECK (true);



CREATE POLICY "Allow public read access" ON "public"."medical_partners" FOR SELECT USING (true);



CREATE POLICY "Allow public read access" ON "public"."reviews" FOR SELECT USING (true);



CREATE POLICY "Allow users and partners to read their appointments" ON "public"."appointments" FOR SELECT USING ((("booking_user_id" = ( SELECT "auth"."uid"() AS "uid")) OR ("partner_id" = ( SELECT "auth"."uid"() AS "uid"))));



CREATE POLICY "Allow users and partners to update their appointments" ON "public"."appointments" FOR UPDATE USING ((("booking_user_id" = ( SELECT "auth"."uid"() AS "uid")) OR ("partner_id" = ( SELECT "auth"."uid"() AS "uid"))));



CREATE POLICY "Allow users to create their own profile" ON "public"."users" FOR INSERT WITH CHECK (("auth"."uid"() = "id"));



CREATE POLICY "Allow users to insert their own appointments" ON "public"."appointments" FOR INSERT WITH CHECK (("booking_user_id" = ( SELECT "auth"."uid"() AS "uid")));



CREATE POLICY "Allow users to read their own notifications" ON "public"."notifications" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Allow users to read their own profile" ON "public"."users" FOR SELECT USING (("auth"."uid"() = "id"));



CREATE POLICY "Enable insert for authenticated users only" ON "public"."appointments" FOR INSERT TO "authenticated" WITH CHECK (true);



CREATE POLICY "Partners can update their own profile" ON "public"."medical_partners" FOR SELECT USING (("auth"."uid"() = "id"));



CREATE POLICY "Partners can update their own settings" ON "public"."medical_partners" FOR UPDATE USING (("auth"."uid"() = "id"));



CREATE POLICY "Partners can view their patients' info" ON "public"."users" FOR SELECT USING (("id" IN ( SELECT "appointments"."booking_user_id"
   FROM "public"."appointments"
  WHERE ("appointments"."partner_id" = "auth"."uid"()))));



CREATE POLICY "Users can manage their own FCM tokens" ON "public"."fcm_tokens" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their own profile" ON "public"."users" FOR UPDATE USING (("auth"."uid"() = "id")) WITH CHECK (("auth"."uid"() = "id"));



ALTER TABLE "public"."appointments" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."fcm_tokens" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."medical_partners" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."notifications" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."reviews" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."users" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."appointments";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."medical_partners";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."users";









GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";














































































































































































GRANT ALL ON FUNCTION "public"."book_appointment"("partner_id_arg" "uuid", "appointment_time_arg" timestamp with time zone, "on_behalf_of_name_arg" "text", "on_behalf_of_phone_arg" "text", "is_partner_override" boolean, "case_description_arg" "text", "patient_location_arg" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."book_appointment"("partner_id_arg" "uuid", "appointment_time_arg" timestamp with time zone, "on_behalf_of_name_arg" "text", "on_behalf_of_phone_arg" "text", "is_partner_override" boolean, "case_description_arg" "text", "patient_location_arg" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."book_appointment"("partner_id_arg" "uuid", "appointment_time_arg" timestamp with time zone, "on_behalf_of_name_arg" "text", "on_behalf_of_phone_arg" "text", "is_partner_override" boolean, "case_description_arg" "text", "patient_location_arg" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."cancel_and_reorder_queue"("appointment_id_arg" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."cancel_and_reorder_queue"("appointment_id_arg" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."cancel_and_reorder_queue"("appointment_id_arg" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."close_day_and_cancel_appointments"("closed_day_arg" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."close_day_and_cancel_appointments"("closed_day_arg" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."close_day_and_cancel_appointments"("closed_day_arg" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."delete_user_account"() TO "anon";
GRANT ALL ON FUNCTION "public"."delete_user_account"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_user_account"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_clinic_appointments"("clinic_id_arg" "uuid", "doctor_id_arg" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_clinic_appointments"("clinic_id_arg" "uuid", "doctor_id_arg" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_clinic_appointments"("clinic_id_arg" "uuid", "doctor_id_arg" "uuid") TO "service_role";



GRANT ALL ON TABLE "public"."medical_partners" TO "anon";
GRANT ALL ON TABLE "public"."medical_partners" TO "authenticated";
GRANT ALL ON TABLE "public"."medical_partners" TO "service_role";



GRANT ALL ON FUNCTION "public"."get_filtered_partners"("category_arg" "text", "state_arg" "text", "specialty_arg" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_filtered_partners"("category_arg" "text", "state_arg" "text", "specialty_arg" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_filtered_partners"("category_arg" "text", "state_arg" "text", "specialty_arg" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_reviews_with_user_names"("partner_id_arg" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_reviews_with_user_names"("partner_id_arg" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_reviews_with_user_names"("partner_id_arg" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_weekly_appointment_stats"("partner_id_arg" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_weekly_appointment_stats"("partner_id_arg" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_weekly_appointment_stats"("partner_id_arg" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_appointment_notification"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_appointment_notification"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_appointment_notification"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_partner_emergency"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_partner_emergency"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_partner_emergency"() TO "service_role";



GRANT ALL ON FUNCTION "public"."reschedule_appointment_to_end_of_queue"("appointment_id_arg" bigint, "partner_id_arg" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."reschedule_appointment_to_end_of_queue"("appointment_id_arg" bigint, "partner_id_arg" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."reschedule_appointment_to_end_of_queue"("appointment_id_arg" bigint, "partner_id_arg" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."search_partners"("search_term" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."search_partners"("search_term" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."search_partners"("search_term" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."send_appointment_reminders"() TO "anon";
GRANT ALL ON FUNCTION "public"."send_appointment_reminders"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."send_appointment_reminders"() TO "service_role";



GRANT ALL ON FUNCTION "public"."submit_review"("appointment_id_arg" bigint, "rating_arg" numeric, "review_text_arg" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."submit_review"("appointment_id_arg" bigint, "rating_arg" numeric, "review_text_arg" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."submit_review"("appointment_id_arg" bigint, "rating_arg" numeric, "review_text_arg" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_completed_appointments"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_completed_appointments"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_completed_appointments"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_partner_rating_aggregates"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_partner_rating_aggregates"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_partner_rating_aggregates"() TO "service_role";
























GRANT ALL ON TABLE "public"."appointments" TO "anon";
GRANT ALL ON TABLE "public"."appointments" TO "authenticated";
GRANT ALL ON TABLE "public"."appointments" TO "service_role";



GRANT ALL ON SEQUENCE "public"."appointments_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."appointments_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."appointments_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."fcm_tokens" TO "anon";
GRANT ALL ON TABLE "public"."fcm_tokens" TO "authenticated";
GRANT ALL ON TABLE "public"."fcm_tokens" TO "service_role";



GRANT ALL ON SEQUENCE "public"."fcm_tokens_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."fcm_tokens_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."fcm_tokens_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."notifications" TO "anon";
GRANT ALL ON TABLE "public"."notifications" TO "authenticated";
GRANT ALL ON TABLE "public"."notifications" TO "service_role";



GRANT ALL ON SEQUENCE "public"."notifications_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."notifications_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."notifications_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."reviews" TO "anon";
GRANT ALL ON TABLE "public"."reviews" TO "authenticated";
GRANT ALL ON TABLE "public"."reviews" TO "service_role";



GRANT ALL ON SEQUENCE "public"."reviews_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."reviews_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."reviews_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."users" TO "anon";
GRANT ALL ON TABLE "public"."users" TO "authenticated";
GRANT ALL ON TABLE "public"."users" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";






























RESET ALL;
