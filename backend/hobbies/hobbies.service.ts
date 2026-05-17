import { prisma } from '../../lib/prisma'

interface HobbyData {
  name: string
  emoji: string
  metaValue: number
  unit: string
  repeat?: boolean
  days?: number[]
  reminderHour?: number
  reminderMin?: number
  notification?: boolean
  paused?: boolean
  categoriaId?: string | null
}

export const listHobbies = (userId: string) =>
  prisma.hobby.findMany({
    where: { userId },
    include: { categoria: true },
    orderBy: { createdAt: 'desc' },
  })

export const getHobby = (id: string, userId: string) =>
  prisma.hobby.findFirst({ where: { id, userId } })

export const createHobby = (userId: string, data: HobbyData) =>
  prisma.hobby.create({
    data: {
      ...data,
      userId,
      days: data.days ?? [],
      reminderHour: data.reminderHour ?? 0,
      reminderMin: data.reminderMin ?? 0,
    },
  })

export const updateHobby = (id: string, data: Partial<HobbyData>) =>
  prisma.hobby.update({ where: { id }, data })

export const deleteHobby = (id: string) =>
  prisma.hobby.delete({ where: { id } })
