import { FastifyRequest, FastifyReply } from 'fastify'
import { listProgresso, createProgresso, deleteProgresso } from './progresso.service'

type HobbyIdParams = { hobbyId: string }
type IdParams = { id: string }
type CreateBody = { valor: number }

export async function list(
  request: FastifyRequest<{ Params: HobbyIdParams }>,
  reply: FastifyReply,
) {
  const itens = await listProgresso(request.params.hobbyId)
  return reply.send(itens)
}

export async function create(
  request: FastifyRequest<{ Params: HobbyIdParams; Body: CreateBody }>,
  reply: FastifyReply,
) {
  const item = await createProgresso(request.params.hobbyId, request.body.valor)
  return reply.code(201).send(item)
}

export async function remove(
  request: FastifyRequest<{ Params: IdParams }>,
  reply: FastifyReply,
) {
  await deleteProgresso(request.params.id)
  return reply.send({ message: 'Progresso removido' })
}
