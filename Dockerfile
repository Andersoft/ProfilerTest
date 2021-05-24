#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/core/sdk:3.1-buster AS build
WORKDIR /src
COPY ["ProfilerTest.csproj", ""]
RUN dotnet restore "./ProfilerTest.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "ProfilerTest.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "ProfilerTest.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

ENV DOTNET_STARTUP_HOOKS="/app/Instana.Tracing.Core.dll"
ENV CORECLR_ENABLE_PROFILING="1"
ENV CORECLR_PROFILER="{8B2CE134-0948-48CA-A4B2-80DDAD9F5791}"
ENV CORECLR_PROFILER_PATH="/app/contrast/runtimes/linux-x64/native/ContrastProfiler.so"
ENV CONTRAST_CCC_CORECLR_PROFILER="{cf0d821e-299b-5307-a3d8-b283c03916dd}"
ENV CONTRAST_CCC_CORECLR_PROFILER_PATH="/app/instana_tracing/CoreProfiler.so"

ENTRYPOINT ["dotnet", "ProfilerTest.dll"]