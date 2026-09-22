# Documentação de modelos (classes) do aplicativo

## Usuario
Classe que implementa um usuário do sistema. Existem dois papéis de usuários - definidos por Enum UserType: Gestor - responsável 
por definir processos produtivos, operações, cadastro de empresas, etc. - e Operador - responsável apenas pelo andamento de processos
produtivos.

    Class Usuario {
        +String nome
        +String email
        +String senha
        +Enum UserType tipo
        
        +Usuario();
        +UserType getUserType();
        +bool validarLogin();
        +String getNomeUsuario();
        +bool alterarSenha(String novaSenha);
    }


## Contato

    Class Contato {
        +String nome;
        +String telefone;

        +Contato();
    }


## Empresa 

    Class Empresa {
        +String cnpj;
        +String nomeFantasia;
        +Contato contato;

    }

## Referência
Referência é um termo utilizado para designar uma modelagem de roupa.
O aplicativo não registra nenhuma informação sobre a referência, apenas seu nome.

    Class Referencia {
        +String nome;

        +Referencia();
    }


## Status
Status utilizado para definir um processo produtivo e uma operação. 
    Enum Status = { concluido, cancelado, emAndamento }

## ProcessoProdutivo
Um processo produtivo é uma de várias etapas necessárias para confecção de uma peça de roupa.

    Class ProcessoProdutivo {
        +String descricao;
        +Empresa empresaResponsavel;
        +DateTime dataInicio; 
        +DateTime dataFim;
        +Enum Status status;
    
        +ProcessoProdutivo();
        +void setEmpresaResponsavel(Empresa empresa);
        +void setDataFim(DateTime dataFim);
        +void setStatus(Status status);
    }


## ItemGrade
Um ItemGrade é uma abstração para um dos itens que compoõem uma grade de um pedido.
Exemplo: Tamanho P - 10 peças

    Class ItemGrade {
        +String descricao;
        +int quantidade;
    }

## Operação
Uma Operação (comumente chamada de OP) define todo o processo produtivo.

    Class Operacao {
        +Referencia referencia;
        +Empresa cliente;
        +DateTime dataEntrega;
        +List<ItemGrade> gradePedido;
        +List<ItemGrade> gradeFabricada;
        +List<ProcessoProdutivo> processos;
        +Enum Status status;
    }