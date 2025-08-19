-- Fix critical security issue: Remove public access to student personal data
-- The alunos_ativos table contains highly sensitive personal information (CPF, emails, phone numbers, financial data)
-- and should only be accessible to authenticated admins

-- Remove the dangerous public select policy
DROP POLICY IF EXISTS "public select alunos_ativos (temporary)" ON public.alunos_ativos;

-- Revoke SELECT permission from anon role for student data
REVOKE SELECT ON public.alunos_ativos FROM anon;

-- The existing admin-only policy remains in place:
-- "Only admins can access alunos_ativos" with has_role(auth.uid(), 'admin'::app_role)

-- For n8n integration with student data, use the n8n-gateway edge function instead of direct REST access
-- This provides proper authentication and audit logging