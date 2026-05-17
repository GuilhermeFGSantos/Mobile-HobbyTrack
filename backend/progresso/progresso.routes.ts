import { FastifyInstance } from 'fastify'
import { list, create, remove } from './progresso.controller'
import { listProgressoSchema, createProgressoSchema, deleteProgressoSchema } from './progresso.schema'

export async function progressoRoutes(app: FastifyInstance) {
  app.addHook('preHandler', app.authenticate)
  app.get('/hobbies/:hobbyId/progresso', { schema: listProgressoSchema }, list)
  app.post('/hobbies/:hobbyId/progresso', { schema: createProgressoSchema }, create)
  app.delete('/progresso/:id', { schema: deleteProgressoSchema }, remove)
}
