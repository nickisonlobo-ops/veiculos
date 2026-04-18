-- Cria o bucket público para fotos de veículos
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'veiculos-fotos',
  'veiculos-fotos',
  true,
  5242880, -- 5 MB
  ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- Permite que usuários autenticados façam upload
CREATE POLICY "Autenticados podem fazer upload de fotos"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'veiculos-fotos');

-- Permite leitura pública das fotos
CREATE POLICY "Fotos visíveis publicamente"
ON storage.objects FOR SELECT TO public
USING (bucket_id = 'veiculos-fotos');

-- Permite que usuários autenticados atualizem fotos
CREATE POLICY "Autenticados podem atualizar fotos"
ON storage.objects FOR UPDATE TO authenticated
USING (bucket_id = 'veiculos-fotos');

-- Permite que usuários autenticados deletem fotos
CREATE POLICY "Autenticados podem deletar fotos"
ON storage.objects FOR DELETE TO authenticated
USING (bucket_id = 'veiculos-fotos');
