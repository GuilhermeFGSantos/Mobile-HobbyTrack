const hobbyProps = {
  name: { type: 'string' },
  emoji: { type: 'string' },
  metaValue: { type: 'integer' },
  unit: { type: 'string' },
  repeat: { type: 'boolean' },
  days: { type: 'array', items: { type: 'integer' } },
  reminderHour: { type: 'integer', minimum: 0, maximum: 23 },
  reminderMin: { type: 'integer', minimum: 0, maximum: 59 },
  notification: { type: 'boolean' },
  paused: { type: 'boolean' },
  categoriaId: { type: 'string', nullable: true },
}

const hobbyResponse = {
  type: 'object',
  properties: {
    id: { type: 'string' },
    ...hobbyProps,
    userId: { type: 'string' },
    createdAt: { type: 'string' },
    updatedAt: { type: 'string' },
  },
}

const secured = { security: [{ bearerAuth: [] }] }

export const listHobbiesSchema = {
  tags: ['Hobbies'], ...secured,
  response: { 200: { type: 'array', items: hobbyResponse } },
}

export const createHobbySchema = {
  tags: ['Hobbies'], ...secured,
  body: {
    type: 'object',
    required: ['name', 'emoji', 'metaValue', 'unit'],
    properties: hobbyProps,
  },
  response: { 201: hobbyResponse },
}

export const updateHobbySchema = {
  tags: ['Hobbies'], ...secured,
  params: { type: 'object', properties: { id: { type: 'string' } } },
  body: { type: 'object', properties: hobbyProps },
  response: { 200: hobbyResponse },
}

export const deleteHobbySchema = {
  tags: ['Hobbies'], ...secured,
  params: { type: 'object', properties: { id: { type: 'string' } } },
  response: { 200: { type: 'object', properties: { message: { type: 'string' } } } },
}
