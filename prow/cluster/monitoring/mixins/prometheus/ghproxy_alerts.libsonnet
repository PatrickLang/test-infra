{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'ghproxy',
        rules: [
          {
            alert: 'ghproxy-specific-status-code-abnormal',
            expr: |||
              sum(rate(github_request_duration_count{status=~"[45]..",status!="404",status!="410"}[5m])) by (status,path) / ignoring(status) group_left sum(rate(github_request_duration_count[5m])) by (path) * 100 > 10
            |||,
            labels: {
              severity: 'warning',
            },
            annotations: {
              message: '{{ $value | humanize }}%% of all requests for {{ $labels.path }} through the GitHub proxy are errorring with code {{ $labels.status }}. Check <https://monitoring.prow.k8s.io/d/%s/github-cache?orgId=1&refresh=1m&fullscreen&panelId=9>' % $._config.grafanaDashboardIDs['ghproxy.json'],
            },
          },
          {
            alert: 'ghproxy-global-status-code-abnormal',
            expr: |||
              sum(rate(github_request_duration_count{status=~"[45]..",status!="404",status!="410"}[5m])) by (status) / ignoring(status) group_left sum(rate(github_request_duration_count[5m])) * 100 > 3
            |||,
            labels: {
              severity: 'warning',
            },
            annotations: {
              message: '{{ $value | humanize }}%% of all API requests through the GitHub proxy are errorring with code {{ $labels.status }}. Check <https://monitoring.prow.k8s.io/d/%s/github-cache?orgId=1&refresh=1m&fullscreen&panelId=8|grafana>' % $._config.grafanaDashboardIDs['ghproxy.json'],
            },
          },
          {
            alert: 'ghproxy-running-out-github-tokens-in-a-hour',
            // check 30% of the capacity (5000): 1500
            expr: |||
              github_token_usage{job="ghproxy"} <  1500
              and
              predict_linear(github_token_usage{job="ghproxy"}[1h], 1 * 3600) < 0
            |||,
            'for': '5m',
            labels: {
              severity: 'warning',
            },
            annotations: {
              message: 'token {{ $labels.token_hash }} will run out of API quota before the next reset.',
            },
          }
        ],
      },
    ],
  },
}
