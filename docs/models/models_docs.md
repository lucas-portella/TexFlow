# Documentação de modelos (classes) do aplicativo

## Usuario
Classe que implementa um usuário do sistema. Existem dois papéis de usuários - definidos por Enum UserType: Gestor - responsável 
por definir processos produtivos, operações, cadastro de empresas, etc. - e Operador - responsável apenas pelo andamento de processos
produtivos.

    Class Usuario {
        +int idUsuario;
        +String nome
        +String email
        +String senha
        +Enum UserType tipo
        
        +Usuario();
        +Usuario fromMap(Map<String, dynamic> map);
        +UserType getUserType();
        +bool validarLogin();
        +String getNomeUsuario();
        +bool alterarSenha(String novaSenha);
        +Map<String,dynamic> toMap();
    }


## Contato

    Class Contato {
        +int idContato;
        +String nome;
        +String telefone;

        +Contato();
        +Contato fromMap(Map<String, dynamic> map);
        +Map<String, dynamic> toMap();
    }


## Empresa 

    Class Empresa {
        +int idEmpresa;
        +String cnpj;
        +String nomeFantasia;
        +Contato contato;

        +Empresa();
        +Empresa fromMap(Map<String, dynamic> map);
        +Map<String, dynamic> toMap();
    }

## Referência
Referência é um termo utilizado para designar uma modelagem de roupa.
O aplicativo não registra nenhuma informação sobre a referência, apenas seu nome.

    Class Referencia {
        +int idReferencia;
        +String nome;

        +Referencia();
        +Referencia fromMap(Map<String, dynamic> map);
        +Map<String, dynamic> toMap();
    }


## Status
Status utilizado para definir um processo produtivo e uma operação. 
    Enum Status = { concluido, cancelado, emAndamento }

## ProcessoProdutivo
Um processo produtivo é uma de várias etapas necessárias para confecção de uma peça de roupa.

    Class ProcessoProdutivo {
        +int idProcessoProdutivo;
        +String descricao;          
        +Empresa empresaResponsavel;    // Empresa responsável pelo serviço
        +DateTime dataInicio;           // Data de início da operação 
        +DateTime dataFim;              // Data de fim da operação
        +Enum Status status;            // Status da operação (não iniciado, em andamento, cancelado, concluído)
        +Usuario alteradoPor;           // Usuário que fez última alteração de status
    
        +ProcessoProdutivo();
        +ProcessoProdutivo fromMap(Map<String, dynamic> map);
        +void setEmpresaResponsavel(Empresa empresa);
        +void setDataFim(DateTime dataFim);
        +void setStatus(Status status);
        +Map<String, dynamic> toMap();
    }


## ItemGrade
Um ItemGrade é uma abstração para um dos itens que compoõem uma grade de um pedido.
Exemplo: Tamanho P - 10 peças

    Class ItemGrade {
        +int idItemGrade;
        +String descricao;
        +int quantidade;

        +ItemGrade();
        +ItemGrade fromMap(Map<String, dynamic> map);
        +Map<String, dynamic> toMap();
    }

## Operação
Uma Operação (comumente chamada de OP) define todo o processo produtivo.

    Class Operacao {
        +int idOperacao;
        +Referencia referencia;
        +Empresa cliente;
        +DateTime dataEntrega;
        +List<ItemGrade> gradePedido;
        +List<ItemGrade> gradeFabricada;
        +List<ProcessoProdutivo> processos;
        +Enum Status status;

        +Operacao();
        +Operacao fromMap(Map<String, dynamic> map);
        +Map<String, dynamic> toMap();
    }