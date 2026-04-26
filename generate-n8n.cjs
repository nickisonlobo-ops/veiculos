const fs = require('fs');
const path = 'c:/Users/nickison.lobo/Desktop/APP/Ve\u00edculos/n8n-agente-veiculos.json';

const ai = (name, desc, type) => `={{ $fromAI('${name}', '${desc}', '${type}') }}`;

const headers = [
  { name: 'Authorization', value: 'Bearer SUA_SERVICE_ROLE_KEY' },
  { name: 'Content-Type', value: 'application/json' }
];

function tool(id, name, toolName, desc, url, bodyParams, pos) {
  return {
    id,
    name,
    type: '@n8n/n8n-nodes-langchain.toolHttpRequest',
    typeVersion: 1.1,
    position: pos,
    parameters: {
      name: toolName,
      description: desc,
      method: 'POST',
      url: 'https://SEU_PROJECT_ID.supabase.co/rest/v1/rpc/' + url,
      authentication: 'predefinedCredentialType',
      nodeCredentialType: 'httpHeaderAuth',
      sendHeaders: true,
      headerParameters: { parameters: headers },
      sendBody: true,
      contentType: 'json',
      specifyBody: 'keypair',
      bodyParameters: { parameters: bodyParams }
    },
    credentials: {
      httpHeaderAuth: { id: 'SUBSTITUA_ID_CREDENCIAL_SUPABASE', name: 'Supabase apikey' }
    }
  };
}

const emp = { name: 'p_empresa_id', value: '1' };

const workflow = {
  name: 'Agente IA - Revenda de Veiculos',
  nodes: [
    {
      id: 'a1b2c3d4-e5f6-4789-8abc-000000000001',
      name: 'Chat',
      type: '@n8n/n8n-nodes-langchain.chatTrigger',
      typeVersion: 1.1,
      position: [0, 300],
      webhookId: 'a1b2c3d4-e5f6-4789-8abc-000000000099',
      parameters: { options: {} }
    },
    {
      id: 'a1b2c3d4-e5f6-4789-8abc-000000000002',
      name: 'Agente IA',
      type: '@n8n/n8n-nodes-langchain.agent',
      typeVersion: 1.7,
      position: [500, 300],
      parameters: {
        options: {
          systemMessage: [
            'Voce e um assistente especializado em revenda de veiculos.',
            'Tem acesso ao banco de dados e pode consultar estoque, clientes, vendas, propostas e financas.',
            '',
            'Regras:',
            '- Responda sempre em portugues',
            '- Seja objetivo e organize em listas',
            '- Para valores monetarios use R$ X.XXX,XX',
            '- O empresa_id ja esta configurado, nao peca ao usuario',
            '- Antes de registrar venda ou proposta, confirme os dados',
            '- Para parametros string opcionais sem filtro, envie string vazia ""',
            '- Para parametros numericos opcionais sem filtro, envie 0'
          ].join('\n'),
          maxIterations: 10
        }
      }
    },
    {
      id: 'a1b2c3d4-e5f6-4789-8abc-000000000003',
      name: 'OpenAI',
      type: '@n8n/n8n-nodes-langchain.lmChatOpenAi',
      typeVersion: 1.1,
      position: [200, 600],
      parameters: { model: 'gpt-4o-mini', options: { temperature: 0.2 } },
      credentials: { openAiApi: { id: 'SUBSTITUA_ID_CREDENCIAL_OPENAI', name: 'OpenAI' } }
    },
    {
      id: 'a1b2c3d4-e5f6-4789-8abc-000000000004',
      name: 'Memoria',
      type: '@n8n/n8n-nodes-langchain.memoryBufferWindow',
      typeVersion: 1.3,
      position: [500, 600],
      parameters: { contextWindowLength: 10 }
    },
    tool('a1b2c3d4-e5f6-4789-8abc-000000000005', 'Dashboard Geral', 'dashboard_geral',
      'Retorna resumo geral: veiculos disponiveis/reservados, vendas do mes, propostas abertas, agendamentos de hoje e receita. Use para status geral ou indicadores.',
      'agente_dashboard', [emp], [1000, 0]),
    tool('a1b2c3d4-e5f6-4789-8abc-000000000006', 'Buscar Veiculos', 'buscar_veiculos',
      'Busca veiculos no estoque com filtros opcionais. Para nao filtrar string use vazia, para numero use 0.',
      'agente_buscar_veiculos', [
        emp,
        { name: 'p_status',    value: ai('status',    'Status: disponivel, reservado, vendido ou inativo. String vazia para todos.', 'string') },
        { name: 'p_marca',     value: ai('marca',     'Marca do veiculo ex: Toyota. String vazia para todas.', 'string') },
        { name: 'p_modelo',    value: ai('modelo',    'Modelo do veiculo ex: Corolla. String vazia para todos.', 'string') },
        { name: 'p_preco_min', value: ai('preco_min', 'Preco minimo em reais. Use 0 para sem limite.', 'number') },
        { name: 'p_preco_max', value: ai('preco_max', 'Preco maximo em reais. Use 0 para sem limite.', 'number') }
      ], [1000, 140]),
    tool('a1b2c3d4-e5f6-4789-8abc-000000000007', 'Resumo do Estoque', 'resumo_estoque',
      'Resumo do estoque: total por status, valor total disponivel e quantidade por marca.',
      'agente_resumo_estoque', [emp], [1000, 280]),
    tool('a1b2c3d4-e5f6-4789-8abc-000000000008', 'Buscar Clientes', 'buscar_clientes',
      'Busca clientes por nome, email, CPF ou telefone. String vazia lista todos.',
      'agente_buscar_clientes', [
        emp,
        { name: 'p_busca', value: ai('busca', 'Nome, email, CPF ou telefone. String vazia lista todos.', 'string') }
      ], [1000, 420]),
    tool('a1b2c3d4-e5f6-4789-8abc-000000000009', 'Criar Cliente', 'criar_cliente',
      'Cadastra novo cliente. Apenas nome e obrigatorio. String vazia para campos nao informados.',
      'agente_criar_cliente', [
        emp,
        { name: 'p_nome',     value: ai('nome',     'Nome completo do cliente. Obrigatorio.', 'string') },
        { name: 'p_email',    value: ai('email',    'Email do cliente. String vazia se nao informado.', 'string') },
        { name: 'p_telefone', value: ai('telefone', 'Telefone do cliente. String vazia se nao informado.', 'string') },
        { name: 'p_cpf',      value: ai('cpf',      'CPF do cliente. String vazia se nao informado.', 'string') },
        { name: 'p_endereco', value: ai('endereco', 'Endereco do cliente. String vazia se nao informado.', 'string') }
      ], [1000, 560]),
    tool('a1b2c3d4-e5f6-4789-8abc-000000000010', 'Registrar Venda', 'registrar_venda',
      'Registra venda e muda status do veiculo para vendido. Use SOMENTE apos confirmacao explicita.',
      'agente_registrar_venda', [
        emp,
        { name: 'p_veiculo_id',  value: ai('veiculo_id',  'ID numerico do veiculo.', 'number') },
        { name: 'p_cliente_id',  value: ai('cliente_id',  'ID numerico do cliente.', 'number') },
        { name: 'p_preco_venda', value: ai('preco_venda', 'Valor final da venda em reais.', 'number') },
        { name: 'p_observacoes', value: ai('observacoes', 'Observacoes. String vazia se nao houver.', 'string') }
      ], [1000, 700]),
    tool('a1b2c3d4-e5f6-4789-8abc-000000000011', 'Listar Vendas', 'listar_vendas',
      'Lista vendas com detalhes do cliente e veiculo. Filtra por mes (1-12) e ano. Use 0 para nao filtrar.',
      'agente_listar_vendas', [
        emp,
        { name: 'p_mes', value: ai('mes', 'Mes de 1 a 12. Use 0 para nao filtrar.', 'number') },
        { name: 'p_ano', value: ai('ano', 'Ano com 4 digitos ex 2026. Use 0 para nao filtrar.', 'number') }
      ], [1000, 840]),
    tool('a1b2c3d4-e5f6-4789-8abc-000000000012', 'Criar Proposta', 'criar_proposta',
      'Cria proposta de venda. Requer id do cliente, id do veiculo e valor proposto.',
      'agente_criar_proposta', [
        emp,
        { name: 'p_cliente_id',  value: ai('cliente_id',  'ID numerico do cliente.', 'number') },
        { name: 'p_veiculo_id',  value: ai('veiculo_id',  'ID numerico do veiculo.', 'number') },
        { name: 'p_valor',       value: ai('valor',       'Valor da proposta em reais.', 'number') },
        { name: 'p_observacoes', value: ai('observacoes', 'Observacoes. String vazia se nao houver.', 'string') }
      ], [1000, 980]),
    tool('a1b2c3d4-e5f6-4789-8abc-000000000013', 'Listar Propostas', 'listar_propostas',
      'Lista propostas com dados do cliente e veiculo. Status: aberta, aceita, recusada ou expirada. String vazia lista todas.',
      'agente_listar_propostas', [
        emp,
        { name: 'p_status', value: ai('status', 'Status: aberta, aceita, recusada ou expirada. String vazia para todas.', 'string') }
      ], [1000, 1120]),
    tool('a1b2c3d4-e5f6-4789-8abc-000000000014', 'Resumo Financeiro', 'resumo_financeiro',
      'Resumo financeiro do mes: receita, despesas e lucro estimado. Tambem lista contas vencidas. Use 0 para mes/ano atual.',
      'agente_resumo_financeiro', [
        emp,
        { name: 'p_mes', value: ai('mes', 'Mes de 1 a 12. Use 0 para mes atual.', 'number') },
        { name: 'p_ano', value: ai('ano', 'Ano com 4 digitos. Use 0 para ano atual.', 'number') }
      ], [1000, 1260]),
    tool('a1b2c3d4-e5f6-4789-8abc-000000000015', 'Contas a Pagar', 'contas_a_pagar',
      'Lista contas a pagar. Status: pendente, pago, vencido ou cancelado. String vazia lista todas.',
      'agente_listar_contas_pagar', [
        emp,
        { name: 'p_status', value: ai('status', 'Status: pendente, pago, vencido ou cancelado. String vazia para todas.', 'string') }
      ], [1000, 1400]),
    tool('a1b2c3d4-e5f6-4789-8abc-000000000016', 'Agendamentos', 'buscar_agendamentos',
      'Busca agendamentos por intervalo de datas YYYY-MM-DD. Status: agendado, confirmado, concluido, cancelado ou faltou. String vazia para todos.',
      'agente_buscar_agendamentos', [
        emp,
        { name: 'p_data_inicio', value: ai('data_inicio', 'Data de inicio no formato YYYY-MM-DD.', 'string') },
        { name: 'p_data_fim',    value: ai('data_fim',    'Data de fim no formato YYYY-MM-DD.', 'string') },
        { name: 'p_status',      value: ai('status',      'Status do agendamento. String vazia para todos.', 'string') }
      ], [1000, 1540])
  ],
  connections: {
    'Chat':            { main:             [[{ node: 'Agente IA', type: 'main',             index: 0 }]] },
    'OpenAI':          { ai_languageModel: [[{ node: 'Agente IA', type: 'ai_languageModel', index: 0 }]] },
    'Memoria':         { ai_memory:        [[{ node: 'Agente IA', type: 'ai_memory',        index: 0 }]] },
    'Dashboard Geral':   { ai_tool: [[{ node: 'Agente IA', type: 'ai_tool', index: 0 }]] },
    'Buscar Veiculos':   { ai_tool: [[{ node: 'Agente IA', type: 'ai_tool', index: 0 }]] },
    'Resumo do Estoque': { ai_tool: [[{ node: 'Agente IA', type: 'ai_tool', index: 0 }]] },
    'Buscar Clientes':   { ai_tool: [[{ node: 'Agente IA', type: 'ai_tool', index: 0 }]] },
    'Criar Cliente':     { ai_tool: [[{ node: 'Agente IA', type: 'ai_tool', index: 0 }]] },
    'Registrar Venda':   { ai_tool: [[{ node: 'Agente IA', type: 'ai_tool', index: 0 }]] },
    'Listar Vendas':     { ai_tool: [[{ node: 'Agente IA', type: 'ai_tool', index: 0 }]] },
    'Criar Proposta':    { ai_tool: [[{ node: 'Agente IA', type: 'ai_tool', index: 0 }]] },
    'Listar Propostas':  { ai_tool: [[{ node: 'Agente IA', type: 'ai_tool', index: 0 }]] },
    'Resumo Financeiro': { ai_tool: [[{ node: 'Agente IA', type: 'ai_tool', index: 0 }]] },
    'Contas a Pagar':    { ai_tool: [[{ node: 'Agente IA', type: 'ai_tool', index: 0 }]] },
    'Agendamentos':      { ai_tool: [[{ node: 'Agente IA', type: 'ai_tool', index: 0 }]] }
  },
  settings: { executionOrder: 'v1' },
  pinData: {},
  tags: []
};

fs.writeFileSync(path, JSON.stringify(workflow, null, 2), 'utf8');
console.log('OK - arquivo gerado com sucesso');
