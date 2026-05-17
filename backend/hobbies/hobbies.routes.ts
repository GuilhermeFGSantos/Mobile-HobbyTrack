import { FastifyInstance } from 'fastify'
import { list, create, update, remove } from './hobbies.controller'
import {
  listHobbiesSchema,
  createHobbySchema,
  updateHobbySchema,
  deleteHobbySchema,
} from './hobbies.schema'

export async function hobbiesRoutes(app: FastifyInstance) {
  app.addHook('preHandler', app.authenticate)
  app.get('/', { schema: listHobbiesSchema }, list)
  app.post('/', { schema: createHobbySchema }, create)
  app.put('/:id', { schema: updateHobbySchema }, update)
  app.delete('/:id', { schema: deleteHobbySchema }, remove)
}
