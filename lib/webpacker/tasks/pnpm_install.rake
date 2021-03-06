# frozen_string_literal: true

namespace :webpacker do
  desc "Install all JavaScript dependencies as specified via pnpm."
  task pnpm_install: [:environment] do
    valid_node_envs = ["test", "development", "production"]

    node_env = ENV.fetch("NODE_ENV") do
      valid_node_envs.include?(Rails.env) ? Rails.env : "production"
    end

    system({ "NODE_ENV" => node_env }, "pnpm i --frozen-lockfile --shamefully-hoist")
  end
end
