RSpec.describe Kumonos::Envoy do
  let(:definition) do
    filename = File.expand_path('../example/envoy.json', __dir__)
    h = JSON.parse(File.read(filename))
    Kumonos::EnvoyDefinition.from_hash(h)
  end

  specify 'generate' do
    out = JSON.dump(Kumonos::Envoy.generate(definition))
    expect(out).to be_json_as(
      listeners: [
        {
          address: 'tcp://0.0.0.0:9211',
          filters: [
            {
              type: 'read',
              name: 'http_connection_manager',
              config: {
                codec_type: 'auto',
                stat_prefix: 'ingress_http',
                access_log: [{ path: '/dev/stdout' }],
                rds: {
                  cluster: 'nginx',
                  route_config_name: 'default',
                  refresh_delay_ms: 30_000
                },
                filters: [
                  {
                    type: 'decoder',
                    name: 'router',
                    config: {}
                  }
                ]
              }
            }
          ]
        }
      ],
      admin: {
        access_log_path: '/dev/stdout',
        address: 'tcp://0.0.0.0:9901'
      },
      statsd_tcp_cluster_name: 'statsd',
      cluster_manager: {
        clusters: [
          {
            name: 'statsd',
            connect_timeout_ms: 250,
            type: 'strict_dns',
            lb_type: 'round_robin',
            hosts: [{ url: 'tcp://socat:2000' }]
          }
        ],
        cds: {
          cluster: {
            name: 'nginx',
            type: 'strict_dns',
            connect_timeout_ms: 250,
            lb_type: 'round_robin',
            hosts: [
              { url: 'tcp://nginx:80' }
            ]
          },
          refresh_delay_ms: 30_000
        }
      }
    )
  end
end