-- Criar enum para tipos de plano
CREATE TYPE public.plano_tipo AS ENUM ('basico', 'premium', 'admin');

-- Criar enum para permissões
CREATE TYPE public.permissao_tipo AS ENUM (
  'visualizar_dados',
  'criar_registros', 
  'editar_registros',
  'deletar_registros',
  'acessar_relatorios',
  'gerenciar_usuarios',
  'admin_total'
);

-- Tabela de planos disponíveis
CREATE TABLE public.planos (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  nome TEXT NOT NULL,
  tipo plano_tipo NOT NULL,
  descricao TEXT,
  limite_usuarios INTEGER DEFAULT NULL, -- NULL = ilimitado
  limite_atendimentos_mes INTEGER DEFAULT NULL, -- NULL = ilimitado
  preco_mensal DECIMAL(10,2) DEFAULT 0.00,
  ativo BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Tabela de permissões por plano
CREATE TABLE public.plano_permissoes (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  plano_id UUID NOT NULL REFERENCES public.planos(id) ON DELETE CASCADE,
  permissao permissao_tipo NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(plano_id, permissao)
);

-- Tabela de assinatura do usuário
CREATE TABLE public.user_planos (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  plano_id UUID NOT NULL REFERENCES public.planos(id),
  data_inicio TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  data_fim TIMESTAMP WITH TIME ZONE, -- NULL = ativo indefinidamente
  ativo BOOLEAN NOT NULL DEFAULT true,
  atendimentos_usados_mes INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(user_id) -- Um usuário só pode ter um plano ativo
);

-- Inserir planos padrão
INSERT INTO public.planos (nome, tipo, descricao, limite_usuarios, limite_atendimentos_mes, preco_mensal) VALUES
('Visualização', 'basico', 'Acesso apenas para visualização de dados', 1, NULL, 0.00),
('Completo', 'premium', 'Acesso completo para criar e editar dados', 1, NULL, 29.90),
('Administrador', 'admin', 'Acesso total ao sistema', NULL, NULL, 99.90);

-- Inserir permissões para cada plano
-- Plano Básico (Visualização)
INSERT INTO public.plano_permissoes (plano_id, permissao) 
SELECT p.id, 'visualizar_dados'::permissao_tipo
FROM public.planos p WHERE p.tipo = 'basico';

-- Plano Premium (Completo)
INSERT INTO public.plano_permissoes (plano_id, permissao) 
SELECT p.id, unnest(ARRAY[
  'visualizar_dados'::permissao_tipo,
  'criar_registros'::permissao_tipo,
  'editar_registros'::permissao_tipo,
  'acessar_relatorios'::permissao_tipo
])
FROM public.planos p WHERE p.tipo = 'premium';

-- Plano Admin (Total)
INSERT INTO public.plano_permissoes (plano_id, permissao) 
SELECT p.id, unnest(ARRAY[
  'visualizar_dados'::permissao_tipo,
  'criar_registros'::permissao_tipo,
  'editar_registros'::permissao_tipo,
  'deletar_registros'::permissao_tipo,
  'acessar_relatorios'::permissao_tipo,
  'gerenciar_usuarios'::permissao_tipo,
  'admin_total'::permissao_tipo
])
FROM public.planos p WHERE p.tipo = 'admin';

-- Habilitar RLS
ALTER TABLE public.planos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.plano_permissoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_planos ENABLE ROW LEVEL SECURITY;

-- Políticas RLS para planos (todos podem ver os planos disponíveis)
CREATE POLICY "Todos podem ver planos ativos" ON public.planos
FOR SELECT USING (ativo = true);

-- Políticas RLS para permissões (todos podem ver)
CREATE POLICY "Todos podem ver permissões" ON public.plano_permissoes
FOR SELECT USING (true);

-- Políticas RLS para user_planos
CREATE POLICY "Usuários podem ver seu próprio plano" ON public.user_planos
FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Admins podem ver todos os planos de usuários" ON public.user_planos
FOR ALL USING (has_role(auth.uid(), 'admin'::app_role));

-- Função para verificar permissão do usuário
CREATE OR REPLACE FUNCTION public.has_permission(_user_id UUID, _permissao permissao_tipo)
RETURNS BOOLEAN
LANGUAGE SQL
STABLE
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_planos up
    JOIN public.plano_permissoes pp ON up.plano_id = pp.plano_id
    WHERE up.user_id = _user_id
      AND up.ativo = true
      AND pp.permissao = _permissao
      AND (up.data_fim IS NULL OR up.data_fim > now())
  )
$$;

-- Função para obter plano ativo do usuário
CREATE OR REPLACE FUNCTION public.get_user_plano(_user_id UUID)
RETURNS TABLE (
  plano_nome TEXT,
  plano_tipo plano_tipo,
  permissoes permissao_tipo[]
)
LANGUAGE SQL
STABLE
SECURITY DEFINER
AS $$
  SELECT 
    p.nome,
    p.tipo,
    ARRAY_AGG(pp.permissao) as permissoes
  FROM public.user_planos up
  JOIN public.planos p ON up.plano_id = p.id
  JOIN public.plano_permissoes pp ON p.id = pp.plano_id
  WHERE up.user_id = _user_id
    AND up.ativo = true
    AND (up.data_fim IS NULL OR up.data_fim > now())
  GROUP BY p.nome, p.tipo
$$;

-- Trigger para atualizar updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_planos_updated_at
  BEFORE UPDATE ON public.planos
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_user_planos_updated_at
  BEFORE UPDATE ON public.user_planos
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();