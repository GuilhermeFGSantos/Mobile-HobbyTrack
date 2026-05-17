import { prisma } from '../../lib/prisma'

function startOfDay(d: Date) {
  return new Date(d.getFullYear(), d.getMonth(), d.getDate())
}

function startOfWeek(d: Date) {
  const day = d.getDay()
  const diff = (day + 6) % 7
  return startOfDay(new Date(d.getFullYear(), d.getMonth(), d.getDate() - diff))
}

export async function getStats(userId: string) {
  const hobbies = await prisma.hobby.findMany({
    where: { userId },
    select: { id: true },
  })
  const hobbyIds = hobbies.map((h) => h.id)

  if (hobbyIds.length === 0) {
    return { sequenciaAtual: 0, totalSemana: 0, totalSemanaPassada: 0 }
  }

  const now = new Date()
  const inicioSemana = startOfWeek(now)
  const inicioSemanaPassada = new Date(inicioSemana)
  inicioSemanaPassada.setDate(inicioSemanaPassada.getDate() - 7)

  const progressos = await prisma.progresso.findMany({
    where: {
      hobbyId: { in: hobbyIds },
      date: { gte: inicioSemanaPassada },
    },
    select: { valor: true, date: true },
    orderBy: { date: 'desc' },
  })

  // Totais da semana atual e passada
  let totalSemana = 0
  let totalSemanaPassada = 0
  for (const p of progressos) {
    if (p.date >= inicioSemana) totalSemana += p.valor
    else totalSemanaPassada += p.valor
  }

  // Sequência: dias consecutivos com pelo menos 1 progresso
  const allProgressos = await prisma.progresso.findMany({
    where: { hobbyId: { in: hobbyIds } },
    select: { date: true },
    orderBy: { date: 'desc' },
  })

  const diasComProgresso = new Set(
    allProgressos.map((p) => startOfDay(p.date).getTime())
  )

  let sequenciaAtual = 0
  const hoje = startOfDay(now)
  let diaVerificado = hoje

  while (diasComProgresso.has(diaVerificado.getTime())) {
    sequenciaAtual++
    diaVerificado = new Date(diaVerificado.getTime() - 86_400_000)
  }

  // Se hoje não tem progresso, verifica a partir de ontem
  if (sequenciaAtual === 0) {
    diaVerificado = new Date(hoje.getTime() - 86_400_000)
    while (diasComProgresso.has(diaVerificado.getTime())) {
      sequenciaAtual++
      diaVerificado = new Date(diaVerificado.getTime() - 86_400_000)
    }
  }

  return { sequenciaAtual, totalSemana, totalSemanaPassada }
}
