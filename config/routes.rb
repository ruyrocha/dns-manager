Rails.application.routes.draw do
  mount DnsRecords::Api, at: '/api'
  root to: 'home#index'
end
