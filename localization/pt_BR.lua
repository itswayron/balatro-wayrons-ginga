return {
    descriptions = {
        Joker = {
            j_wg_card_in_sleeve = {
                name = "Carta na Manga",
                text = {
                    "Cartas jogadas também contam",
                    "como cartas {C:attention}na mão{}"
                }
            },
            j_wg_another_one = {
                name = "Tem Outra",
                text = {
                    "Cartas {C:attention}na mão{}",
                    "também contam como cartas {C:attention}jogadas{},",
                    "{C:red}#1#{} no tamanho da mão"
                }
            },
            j_wg_occultist = {
                name = "Ocultista",
                text = {
                    "Ao selecionar um {C:attention}Blind{},",
                    "{C:green}#1# em #2#{} chance de",
                    "criar uma Carta {C:spectral}Espectral{}",
                    "{C:inactive}(Precisa ter espaço){}"
                }
            },
            j_wg_vibe_coder = {
                name = "Vibe Coder",
                text = {
                    "Ao selecionar um {C:attention}Blind{},",
                    "{C:green}#1# em #2#{} chance de copiar a",
                    "habilidade de um {C:attention}Coringa aleatório{}",
                    "durante todo o Blind"
                }
            },
            j_wg_leftmost_zero = {
                name = "0 à Esquerda",
                text = {
                    "O Coringa mais {C:attention}à esquerda{}",
                    "se torna {C:dark_edition}Negativo{}",
                    "{C:inactive}(Ignora Coringas Negativos){}"
                }
            },
            j_wg_stack_overflow = {
                name = "Stack Overflow",
                text = {
                    "Todos os efeitos de {C:attention}reativação{}",
                    "têm {C:green}#1# em #2#{} chances de",
                    "{C:attention}reativar novamente{}",
                    "{C:inactive}(Inclui reativações deste próprio Coringa){}",
                    "{C:inactive}(Não é afetado pelo {C:attention,T:j_oops}dado{C:inactive}){}"
                }
            }
        },
        Voucher = {
            v_wg_scalper = {
                name = "Cambista",
                text = {
                    "Todos os {C:attention}Consumíveis{} são vendidos",
                    "por {C:money}+#1#{} acima do preço pago"
                }
            },
            v_wg_dollar_dealer = {
                name = "Doleiro",
                text = {
                    "Todos os {C:attention}Consumíveis{} são vendidos por",
                    "{C:money}+#1#{} adicionais {C:inactive}(+#2# no total){}"
                }
            }
        },
        Back = {
            b_wg_battery = {
                name = "Deck Bateria",
                text = {
                    "Pontuação excedente de Blinds vencidos",
                    "recarrega a sua {C:attention}Bateria{}.",
                    "Capacidade máxima de {C:attention}2X a soma{}",
                    "de todos os Blinds do Ante.",
                    "Na {C:attention}última mão{}, usa a carga se necessário.",
                    "{C:red}X#1#{} tamanho base dos Blinds"
                }
            }
        },
        Sleeve = {
            sleeve_wg_battery = {
                name = "Bateria Sleeve",
                text = {
                    "Pontuação excedente recarrega a sua {C:attention}Bateria{}.",
                    "Capacidade de {C:attention}2X a soma{} dos Blinds do Ante.",
                    "Usa a carga da bateria na {C:attention}última mão{}.",
                    "{C:red}X#1#{} tamanho base dos Blinds"
                }
            },
            sleeve_wg_battery_alt = {
                name = "Bateria Sleeve",
                text = {
                    "Recarrega {C:attention}2X{} mais rápido,",
                    "descarrega {C:attention}2X{} mais devagar",
                    "e tem {C:attention}Capacidade Infinita{}"
                }
            }
        }
    },
    misc = {
        dictionary = {
            k_wg_sleeve = "Na Manga!",
            k_wg_another_one = "Tem Outra!",
            k_wg_vibe_success = "Compilou!",
            k_wg_vibe_fail = "Bug...",
            k_wg_vibe_copying = "Copiando: #1#",
            k_wg_vibe_inactive = "Inativo",
            k_wg_vibe_failed = "Falhou neste Blind",
            k_wg_zero_target = "Negativo: #1#",
            k_wg_reserve = "Bateria: ",
            k_wg_stored = " na Bateria!",
            k_wg_from_reserve = " da Bateria!",
            k_wg_stored_splash = "+#1# Carga da Bateria!",
            k_wg_from_reserve_splash = "+#1# Usado da Bateria!",
            k_wg_battery_full = "Bateria Cheia!",
            k_wg_battery_max_tag = " (MÁX)",
            k_plus_spectral = "+1 Espectral",
            jdis_wg_played_to_hand = "#1# -> Mão",
            jdis_wg_hand_to_played = "#1# -> Jogadas",
            jdis_wg_hand_size = "Tam. Mão",
            jdis_wg_random = "Aleatório"
        }
    }
}
