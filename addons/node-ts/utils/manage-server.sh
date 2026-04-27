#!/bin/bash
#
# Gestor del backend dev en background.
# Uso: ./utils/manage-server.sh [start|stop|restart|status|logs [follow]]
#
# Configurable por variables de entorno:
#   - LOG_DIR (default: ./logs)
#   - DEV_CMD (default: "pnpm dev")
#   - PROCESS_PATTERN (default: "tsx watch src/")  # patrón para pkill de huérfanos
#
# Patrón:
#   - PID en LOG_DIR/backend.pid
#   - Logs centralizados en LOG_DIR/backend-dev.log (append, separador por sesión)

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

LOG_DIR="${LOG_DIR:-$PROJECT_ROOT/logs}"
LOG_FILE="$LOG_DIR/backend-dev.log"
PID_FILE="$LOG_DIR/backend.pid"
DEV_CMD="${DEV_CMD:-pnpm dev}"
PROCESS_PATTERN="${PROCESS_PATTERN:-tsx watch src/}"

cd "$PROJECT_ROOT" || exit 1

case "${1:-}" in
  start)
    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
      echo "Servidor ya está corriendo (PID: $(cat "$PID_FILE"))"
      exit 1
    fi

    echo "Iniciando servidor..."
    mkdir -p "$LOG_DIR"

    # Separador de sesión en el log (append mode)
    {
      echo ""
      echo "========================================"
      echo "=== SERVER START: $(date -Iseconds) ==="
      echo "========================================"
    } >> "$LOG_FILE"

    # setsid + nohup desliga el proceso del shell actual
    setsid bash -c "cd '$PROJECT_ROOT' && nohup $DEV_CMD >> '$LOG_FILE' 2>&1 & echo \$! > '$PID_FILE'" </dev/null >/dev/null 2>&1 &

    sleep 4

    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
      echo "Servidor iniciado (PID: $(cat "$PID_FILE"))"
      echo "Logs: $LOG_FILE"
      tail -20 "$LOG_FILE"
    else
      echo "Error al iniciar el servidor"
      rm -f "$PID_FILE"
      exit 1
    fi
    ;;

  stop)
    if [ ! -f "$PID_FILE" ]; then
      echo "No hay PID file. Buscando procesos huérfanos..."
      pkill -f "$PROCESS_PATTERN"
      echo "Procesos detenidos"
      exit 0
    fi

    PID=$(cat "$PID_FILE")
    echo "Deteniendo servidor (PID: $PID)..."

    pkill -P "$PID" 2>/dev/null || true
    kill "$PID" 2>/dev/null || true
    sleep 2

    if kill -0 "$PID" 2>/dev/null; then
      kill -9 "$PID" 2>/dev/null || true
    fi

    pkill -f "$PROCESS_PATTERN" 2>/dev/null || true

    rm -f "$PID_FILE"
    echo "Servidor detenido"
    ;;

  restart)
    "$0" stop
    sleep 2
    "$0" start
    ;;

  status)
    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
      PID=$(cat "$PID_FILE")
      echo "Servidor corriendo (PID: $PID)"
      ps aux | grep "$PID" | grep -v grep
      echo ""
      echo "Últimas líneas del log:"
      tail -10 "$LOG_FILE"
    else
      echo "Servidor NO está corriendo"
      if pgrep -f "$PROCESS_PATTERN" > /dev/null; then
        echo "Pero hay procesos huérfanos:"
        ps aux | grep "$PROCESS_PATTERN" | grep -v grep
      fi
    fi
    ;;

  logs)
    if [ ! -f "$LOG_FILE" ]; then
      echo "No hay archivo de log en $LOG_FILE"
      exit 1
    fi
    if [ "${2:-}" == "follow" ] || [ "${2:-}" == "-f" ]; then
      tail -f "$LOG_FILE"
    else
      tail -50 "$LOG_FILE"
    fi
    ;;

  *)
    cat <<USAGE
Uso: $0 {start|stop|restart|status|logs [follow]}

Comandos:
  start         Inicia el servidor en background
  stop          Detiene el servidor (incluye huérfanos)
  restart       Reinicia el servidor
  status        Estado actual + últimas 10 líneas de log
  logs          Últimas 50 líneas de log
  logs follow   Monitorea logs en tiempo real (-f)

Variables de entorno:
  LOG_DIR           default: ./logs
  DEV_CMD           default: 'pnpm dev'
  PROCESS_PATTERN   default: 'tsx watch src/'  (para limpiar huérfanos)
USAGE
    exit 1
    ;;
esac
