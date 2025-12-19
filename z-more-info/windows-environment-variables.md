# Exporting environment variables in Windows

Unlike Linux and macOS (which use the `export` command), Windows can use `env` or `set` depending on your shell.
Use these commands to set environment variables on your system. 

**Powershell example**:

```ps
$Env:TF_VAR_db_username = "admin"; $Env:TF_VAR_db_password = "adifferentpassword"
```

or, for persistent variables:

```ps
[Environment]::SetEnvironmentVariable("VARIABLE_NAME", "value", "User")
```

> Note: close and reopen PowerShell to take effect.

**Command Prompt example**:

```cmd
set "TF_VAR_db_username=admin" & set "TF_VAR_db_password=adifferentpassword"
```

> Note: `set` is not persistent. For persistence, use `setx`. Close and reopen the Command Prompt to take effect.
