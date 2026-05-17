import { FastifyRequest, FastifyReply } from 'fastify'
import * as service from './hobbies.service'

type HobbyBody = {
  name: string; emoji: string; metaValue: number; unit: string
  repeat?: boolean; days?: number[]; reminderHour?: number
  reminderMin?: number; notification?: boolean; paused?: boolean; categoriaId?: string
}
type IdParam = { id: string }

export const list = async (req: FastifyRequest, rep: FastifyReply) =>
  rep.send(await service.listHobbies(req.user.id))

export const create = async (
  req: FastifyRequest<{ Body: HobbyBody }>,
  rep: FastifyReply,
) => rep.code(201).send(await service.createHobby(req.user.id, req.body))

export const update = async (
  req: FastifyRequest<{ Params: IdParam; Body: Partial<HobbyBody> }>,
  rep: FastifyReply,
) => {
  const hobby = await service.getHobby(req.params.id, req.user.id)
  if (!hobby) return rep.code(404).send({ message: 'Hobby não encontrado' })
  return rep.send(await service.updateHobby(req.params.id, req.body))
}

export const remove = async (
  req: FastifyRequest<{ Params: IdParam }>,
  rep: FastifyReply,
) => {
  const hobby = await service.getHobby(req.params.id, req.user.id)
  if (!hobby) return rep.code(404).send({ message: 'Hobby não encontrado' })
  await service.deleteHobby(req.params.id)
  return rep.send({ message: 'Hobby excluído com sucesso' })
}
