
$AppName = 'MyAccount-Company'

dotnet new sln -n $AppName
dotnet new mvc -o ".\src\$AppName-App" -n "$AppName-App"
dotnet new classlib -o ".\src\$AppName-Common" -n "$AppName-Common"
dotnet new classlib -o ".\src\$AppName-Models" -n "$AppName-Models"
dotnet new classlib -o ".\src\$AppName-Repo" -n "$AppName-Repo"
dotnet new classlib -o ".\src\$AppName-Svc" -n "$AppName-Svc"
dotnet sln "$AppName.sln" add ".\src\$AppName-App\$AppName-App.csproj" --in-root
dotnet sln "$AppName.sln" add ".\src\$AppName-Common\$AppName-Common.csproj" --in-root
dotnet sln "$AppName.sln" add ".\src\$AppName-Models\$AppName-Models.csproj" --in-root
dotnet sln "$AppName.sln" add ".\src\$AppName-Repo\$AppName-Repo.csproj" --in-root
dotnet sln "$AppName.sln" add ".\src\$AppName-Svc\$AppName-Svc.csproj" --in-root
