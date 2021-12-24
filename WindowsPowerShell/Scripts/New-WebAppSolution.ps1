$AppName = 'Company'

mkdir "/git/$AppName/src"

cd "/git/$AppName"

dotnet new sln -o "./src/" -n $AppName
dotnet new mvc -o "./src/$AppName.App" -n "$AppName.App" --framework netcoreapp3.1
dotnet new classlib -o "./src/$AppName.Common" -n "$AppName.Common" --framework netcoreapp3.1
dotnet new classlib -o "./src/$AppName.Models" -n "$AppName.Models" --framework netcoreapp3.1
dotnet new classlib -o "./src/$AppName.Repo" -n "$AppName.Repo" --framework netcoreapp3.1
dotnet new classlib -o "./src/$AppName.Svc" -n "$AppName.Svc" --framework netcoreapp3.1
dotnet sln "./src/$AppName.sln" add "./src/$AppName.App/$AppName.App.csproj" --in-root
dotnet sln "./src/$AppName.sln" add "./src/$AppName.Common/$AppName.Common.csproj" --in-root
dotnet sln "./src/$AppName.sln" add "./src/$AppName.Models/$AppName.Models.csproj" --in-root
dotnet sln "./src/$AppName.sln" add "./src/$AppName.Repo/$AppName.Repo.csproj" --in-root
dotnet sln "./src/$AppName.sln" add "./src/$AppName.Svc/$AppName.Svc.csproj" --in-root

foreach ($f in (ls "/git/$AppName/src" -File -Recurse)) {
    if ($f.name -eq 'Class1.cs') {
        rm $($f.fullname)
    }
}
