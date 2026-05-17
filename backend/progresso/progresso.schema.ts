const progressoResponse = {
  type: 'object',
  properties: {
    id: { type: 'string' },
    hobbyId: { type: 'string' },
    valor: { type: 'integer' },
    date: { type: 'string' },
  },
}

const secured = { security: [{ bearerAuth: [] }] }

export const listProgressoSchema = {
  tags: ['Progresso'], ...secured,
  params: { type: 'object', properties: { hobbyId: { type: 'string' } } },
  response: { 200: { type: 'array', items: progressoResponse } },
}

export const createProgressoSchema = {
  tags: ['Progresso'], ...secured,
  params: { type: 'object', properties: { hobbyId: { type: 'string' } } },
  body: {
    type: 'object',
    required: ['valor'],
    properties: { valor: { type: 'integer', minimum: 0 } },
  },
  response: { 201: progressoResponse },
}

export const deleteProgressoSchema = {
  tags: ['Progresso'], ...secured,
  params: { type: 'object', properties: { id: { type: 'string' } } },
  response: { 200: { type: 'object', properties: { message: { type: 'string' } } } },
}
