import { prisma } from '../../lib/prisma'

export const listProgresso = (hobbyId: string) =>
  prisma.progresso.findMany({
    where: { hobbyId },
    orderBy: { date: 'desc' },
  })

export const createProgresso = (hobbyId: string, valor: number) =>
  prisma.progresso.create({ data: { hobbyId, valor } })

export const deleteProgresso = (id: string) =>
  prisma.progresso.delete({ where: { id } })
