# Используем официальный образ .NET 8.0 SDK для сборки
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Копируем файл проекта и восстанавливаем зависимости
COPY ["backend/backend.csproj", "./backend/"]
RUN dotnet restore "backend/backend.csproj"

# Копируем весь код и собираем проект
COPY . .
WORKDIR "/src/backend"
RUN dotnet build "backend.csproj" -c Release -o /app/build

# Публикуем приложение
FROM build AS publish
WORKDIR "/src/backend"
RUN dotnet publish "backend.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Финальный образ
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Копируем опубликованное приложение
COPY --from=publish /app/publish .

# Создаем папку для отчетов
RUN mkdir -p /app/Reports

# Открываем порт 5000
EXPOSE 5000

# Запускаем приложение
ENTRYPOINT ["dotnet", "backend.dll"]

