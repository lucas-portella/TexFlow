# Documentação de modelos (classes) do aplicativo

## User

    Class User {
        +String name
        +String email
        +String password
        +Enum UserType type
        
        +User()
        +UserType getUserType()
        +bool validateLogin()
        +String getUserName()
        +bool changeUserPassword(String newPassword)
    }

    Class Op {

    }