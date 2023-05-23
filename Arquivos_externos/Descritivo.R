library(openxlsx)

# Decodificação

codigo = c("TIPOBITO", "DTOBITO", "HORAOBITO", "CODMUNRES", "LOCOCOR", "IDADE", "SEXO", "RACACOR", "ESTCIV", "ESC", "OCUP", "CODMUNOCOR", "CODMUNNATU", "DTNASC", "HORANASC", "NATURAL", "ESCMAE", "ESCMAE2010", "OCUPMAE", "OCUPMAE2010", "QTDFILVIVO", "QTDFILMORT", "CODMUNRES_PAIS", "TPMORTEOCO", "ATESTANTE", "STDOEPIDEM", "CODINST", "TPPOS", "TPNIVELINV", "LOCOCORINVA", "CODIFICADO", "VERSAOSIST", "DTRECEBIM", "NUDIASOBCO", "NUIFMED", "DTATESTADO", "NUIDADE", "PECULIAR", "COMUNSVOIM", "MORTEPARTO", "DTRECORIG", "NATURALIDADE", "CODMUNNATU_A", "ESCMAEAGR1", "ESCMAEAGR2", "ESCFALAGR1", "ESCFALAGR2", "ESCMAE2010_A", "STDOEPIDEM_A", "STDONOVA", "STDONOVA_A", "CODMUNRES_RG", "TPMORTEOCO_A", "TPRESGINFO", "TPRESGINFO_A", "TPFUNDO", "INSTRADM", "INSTRADM_A", "NATURAL_A", "VERSAOSIST_A", "FONTESUS", "FONTESUS_A", "DTINVESTIG", "DTCONINV", "TPINVESTIG", "TPINVESTIG_A", "DTRECORIG_A", "ESCMAE2010_A", "CODMUNNATU_A", "COMUNSVOIM_A", "CODMUNRES_RG_A")

significado = c("Tipo de óbito", "Data do óbito", "Hora do óbito", "Código do município de residência", "Local do óbito", "Idade", "Sexo", "Raça/cor", "Estado civil", "Escolaridade", "Ocupação", "Código do município de ocorrência", "Código do município de nascimento", "Data de nascimento", "Hora de nascimento", "Naturalidade", "Escolaridade da mãe", "Escolaridade da mãe (2010)", "Ocupação da mãe", "Ocupação da mãe (2010)", "Quantidade de filhos vivos", "Quantidade de filhos mortos", "Código do município de residência dos pais", "Tipo de morte - Ocorrência", "Atestante", "Situação do óbito em relação à epidemia", "Código da instituição", "Tipo de parto - Ocorrência", "Tipo de nível de investigação", "Local da ocorrência da malformação", "Causa básica de óbito codificada", "Versão do sistema", "Data de recebimento", "Número de dias entre o óbito e a causa básica", "Número de internações", "Data do atestado", "Número de idade", "Causa básica de óbito peculiar", "Outras causas de morte específicas", "Óbito relacionado ao parto", "Data de recebimento original", "Naturalidade", "Código do município de nascimento (A)", "Escolaridade da mãe agrupada (2010)", "Escolaridade da mãe agrupada (2010)", "Escolaridade do pai agrupada (2010)", "Escolaridade do pai agrupada (2010)", "Escolaridade da mãe (2010) (A)", "Situação do óbito em relação à epidemia (A)", "Nova forma de preenchimento", "Nova forma de preenchimento (A)", "Código do município de residência dos RGs", "Tipo de morte - Ocorrência (A)", "Tipo de resposta", "Tipo de resposta (A)", "Tipo de fundo", "Instrução de admissão", "Instrução de admissão (A)", "Naturalidade (A)", "Versão do sistema (A)", "Fonte de financiamento - SUS", "Fonte de financiamento - SUS (A)", "Data da investigação", "Data do consentimento para investigação", "Tipo de investigação", "Tipo de investigação (A)", "Data de recebimento original (A)", "Escolaridade da mãe (2010) (A)", "Código do município de nascimento (A)", "Outras causas de morte específicas (A)", "Código do município de residência dos RGs (A)")

decodificacao = data.frame(codigo, significado, stringsAsFactors = FALSE)

# Defina as categorias e seus respectivos valores de decodificação
# Cria um dataframe com 40 colunas e 20 linhas preenchidas com NA
df = data.frame(matrix(NA, nrow = 20, ncol = 93))

vetores <- list(
  TIPOBITO = c(1),
  Desc_TIPOBITO = c("Óbito fetal", "Óbito não fetal"),
  
  IDADE1 = c("000", "001", "405", "410", "415", "420", "425", "430", "435", "440", "445", "450", "455", "460", "465", "470", "475", "480", "485", "490"),
  IDADE2 = c("099", "404", "409", "414", "419", "424", "429", "434", "439", "444", "449", "454", "459", "464", "469", "474", "479", "484", "489"),
  Desc_IDADE = c("Ignorado", "0-4", "5-9", "10-14", "15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49", "50-54", "55-59", "60-64", "65-69", "70-74", "75-79", "80-84", "85-89", "90+"),
  
  SEXO = c("I", "F", "M"),
  SEXO_DESC = c("Ignorado", "Feminino", "Masculino"),
  
  RACACOR = c(1, 2, 3, 4, 5),
  RACACOR_DESC = c("Branca", "Preta", "Amarela", "Parda", "Indígena"),
  
  ESTCIV = c(1, 2, 3, 4, 5, 9),
  ESTCIV_DESC = c("Solteiro", "Casado", "Viúvo", "Separado judicialmente/divorciado", "União estável", "Ignorado"),
  
  ESC = c(0, 1, 2, 3, 4, 5, 9),
  ESC_DESC = c("Sem escolaridade", "Fundamental I (1ª a 4ª série)", "Fundamental II (5ª a 8ª série)", "Médio (antigo 2º Grau)", "Superior incompleto", "Superior completo", "Ignorado"),
  
  LOCOCOR = c(1, 2, 3, 4, 5, 6, 9),
  DESC_LOCOCOR = c("Hospital","Outros estabelecimentos de saúde","Domicílio","Via pública","Outros","Aldeia indígena","Ignorado"),
  
  IDADEMAE1 = c(10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90),
  IDADEMAE2 = c(14, 19, 24, 29, 34, 39, 44, 49, 54, 59, 64, 69, 74, 79, 84, 89),
  DESC_IDADEMAE = c("10-14","15-19","20-24","25-29","30-34","35-39","40-44","45-49","50-54","55-59","60-64","65-69","70-74","75-79","80-84","85-89","90+"),
  
  ESCMAE2010 = c(0, 1, 2, 3, 4, 5, 9),
  DESC_ESCMAE2010 = c("Sem escolaridade","Fundamental I (1ª a 4ª série)","Fundamental II (5ª a 8ª série)","Médio (antigo 2º Grau)","Superior incompleto","Superior completo","Ignorado"),
  
  QTdecodificacaoILVIVO = c(9),
  DESC_QTdecodificacaoILVIVO = c("Ignorado"),
  
  QTdecodificacaoILMORT = c(9),
  DESC_QTdecodificacaoILMORT = c("Ignorado"),
  
  SEMAGESTAC = c(99),
  DESC_SEMAGESTAC = c("Ignorada"),
  
  GESTACAO = c(1, 2, 3, 4, 5, 6, 9),
  DESC_GESTACAO = c("Menos de 22 semanas","22 a 27 semanas","28 a 31 semanas","32 a 36 semanas","37 a 41 semanas","42 e + semanas", "Ignorado"),
  
  GRAVIDEZ = c(1, 2, 3, 9),
  GRAVIDEZ_DESC = c("Única", "Dupla", "Tripla e mais", "Ignorada"),
  
  PARTO = c(1, 2, 9),
  PARTO_DESC = c("Vaginal", "Cesáreo", "Ignorado"),
  
  OBITOPARTO = c(1, 2, 3, 9),
  OBITOPARTO_DESC = c("Antes", "Durante", "Depois", "Ignorado"),
  
  PESO1 = c(0, 2500, 3000, 4000),
  PESO2 = c(2499, 2999, 3999),
  PESO_DESC = c("Baixo", "Insuficiente", "Adequado", "Excesso"),
  
  TPMORTEOCO = c(1, 2, 3, 4, 5, 8, 9),
  TPMORTEOCO_DESC = c("Gravidez", "Parto", "Abortamento", "Até 42 dias após o término do parto", "De 43 dias a 1 ano após o término da gestação", "Não ocorreu nestes períodos", "Ignorado"),
  
  ASSISTMED = c(1, 2, 9),
  ASSISTMED_DESC = c("Sim", "Não", "Ignorado"),
  
  NECROPSIA = c(1, 2, 9),
  NECROPSIA_DESC = c("Sim", "Não", "Ignorado"),
  
  CIRCOBITO = c(1, 2, 3, 4, 9),
  CIRCOBITO_DESC = c("Acidente", "Suicídio", "Homicídio", "Outros", "Ignorado"),
  
  ACIDTRAB = c(1, 2, 9),
  ACIDTRAB_DESC = c("Sim", "Não", "Ignorado"),
  
  FONTE = c(1, 2, 3, 4, 9),
  FONTE_DESC = c("Ocorrência policial", "Hospital", "Família", "Outra", "Ignorado"),
  
  ORIGEM = c(1, 2, 3, 9),
  ORIGEM_DESC = c("Oracle", "Banco estadual diponibilizado via FTP", "Banco SEADE", "Ignorado"),
  
  ESC = c(1, 2, 3, 4, 5, 9),
  ESC_DESC = c("Nenhuma", "De 1 a 3 anos", "De 4 a 7 anos", "De 8 a 11 anos", "12 anos e mais", "Ignorado"),
  
  ESCMAE = c(1, 2, 3, 4, 5, 9),
  ESCMAE_DESC = c("Nenhuma", "De 1 a 3 anos", "De 4 a 7 anos", "De 8 a 11 anos", "12 anos e mais", "Ignorado"),
  
  OBITOGRAV = c(1, 2, 9),
  OBITOGRAV_DESC = c("Sim", "Não", "Ignorado"),
  
  OBITOPUERP = c(1, 2, 3, 9),
  OBITOPUERP_DESC = c("Sim, até 42 dias após o parto", "Sim, de 43 dias a 1 ano", "Não", "Ignorado"),
  
  EXAME = c(1, 2, 9),
  EXAME_DESC = c("Sim", "Não", "Ignorado"),
  
  CIRURGIA = c(1, 2, 9),
  CIRURGIA_DESC = c("Sim", "Não", "Ignorado"),
  
  STCODIFICA = c("S", "N"),
  STCODIFICA_DESC = c("Codificadora", "Não codificadora"),
  
  CODIFICADO = c("S", "N"),
  CODIFICADO_DESC = c("Codificado", "Não codificado"),
  
  FONTEINV = c(1, 2, 3, 4, 5, 6, 7, 8, 9),
  FONTEINV_DESC = c("Comitê de Morte Materna e/ou Infantil", "Visita domiciliar / Entrevista família", "Estabelecimento de Saúde / Prontuário", "Relacionado com outros bancos de dados", "S V O", "I M L", "Outra fonte", "Múltiplas fontes", "Ignorado"),
  
  ESCMAEAGR1 = c(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12),
  Desc_ESCMAEAGR1 = c("Sem escolaridade", "Fundamental I Incompleto", "Fundamental I Completo","Fundamental II Incompleto", "Fundamental II Completo", "Ensino Médio Incompleto","Ensino Médio Completo", "Superior Incompleto", "Superior Completo", "Ignorado","Fundamental I Incompleto ou Inespecífico", "Fundamental II Incompleto ou Inespecífico","Ensino Médio Incompleto ou Inespecífico"),
  
  ESCFALAGR1 = c(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12),
  Desc_ESCFALAGR1 = c("Sem escolaridade", "Fundamental I Incompleto", "Fundamental I Completo","Fundamental II Incompleto", "Fundamental II Completo", "Ensino Médio Incompleto","Ensino Médio Completo", "Superior Incompleto", "Superior Completo", "Ignorado","Fundamental I Incompleto ou Inespecífico", "Fundamental II Incompleto ou Inespecífico","Ensino Médio Incompleto ou Inespecífico"),
  
  STDOEPIDEM = c(1, 0),
  Desc_STDOEPIDEM = c("Sim", "Não"),
  
  STDONOVA = c(1, 0),
  Desc_STDONOVA = c("Sim", "Não"),
  
  TPOBITOCOR = c(1, 2, 3, 4, 5, 6, 7, 8, 9, "Branco"),
  Desc_TPOBITOCOR = c("Durante a gestação", "Durante o abortamento", "Após o abortamento","No parto ou até 1 hora após o parto", "No puerpério - até 42 dias após o parto","Entre 43 dias e até 1 ano após o parto", "A investigação não identificou o momento do óbito","Mais de um ano após o parto", "O óbito não ocorreu nas circunstâncias anteriores","Não investigado"),
  
  TPRESGINFO = c("01", "02", "03"),
  Desc_TPRESGINFO = c("Não acrescentou nem corrigiu informação", "Sim, permitiu o resgate de novas informações","Sim, permitiu a correção de alguma das causas informadas originalmente"),
  
  TPNIVELINV = c("E", "R", "M"),
  Desc_TPNIVELINV = c("Estadual", "Regional", "Municipal"),
  
  MORTEPARTO = c(1, 2, 3, 9),
  Desc_MORTEPARTO = c("Antes", "Durante", "Após", "Ignorado"),
  
  ALTCAUSA = c(1, 2),
  Desc_ALTCAUSA = c("Sim", "Não"),
  
  TPPOS = c(1, 2),
  Desc_TPPOS = c("Sim", "Não"),
  
  GESTACAO = c(1, 2, 3, 4, 5, 6),
  Desc_GESTACAO = c("Menos de 22 semanas", "22 a 27 semanas", "28 a 31 semanas", "32 a 36 semanas","37 a 41 semanas", "42 e + semanas"),
  
  CIRURGIA = c(1, 2, 9),
  Desc_CIRURGIA = c("Sim", "Não", "Ignorado")
  
)

# Loop para inserir os vetores nas colunas correspondentes
for (i in seq_len(min(length(vetores), ncol(df)))) {
  df[, i] = c(vetores[[i]], rep(NA, nrow(df) - length(vetores[[i]])))
  colnames(df)[i] = names(vetores)[i]
}

# Salva em xlsx

write.xlsx(df, "Descricao.xlsx", rownames = FALSE)