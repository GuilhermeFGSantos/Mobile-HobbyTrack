import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify'
import { getStats } from './stats.service'

export async function statsRoutes(app: FastifyInstance) {
  app.get(
    '/stats',
    {
      schema: {
        security: [{ bearerAuth: [] }],
        tags: ['Stats'],
        response: {
          200: {
            type: 'object',
            properties: {
              sequenciaAtual: { type: 'integer' },
              totalSemana: { type: 'integer' },
              totalSemanaPassada: { type: 'integer' },
            },
          },
        },
      },
      preHandler: [app.authenticate],
    },
    async (req: FastifyRequest, rep: FastifyReply) => {
      const stats = await getStats(req.user.id)
      return rep.send(stats)
    },
  )
}
