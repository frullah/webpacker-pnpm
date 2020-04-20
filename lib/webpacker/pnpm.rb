# frozen_string_literal: true

require "webpacker/pnpm/version"
require "webpacker/pnpm/railtie"

module Webpacker
  module PNPM
    Webpacker::Compiler.watched_paths.delete("yarn.lock")
    Webpacker::Compiler.watched_paths << "pnpm-lock.yaml"

    # manually add the bin directory so that command won't try to execute via yarn
    ENV["WEBPACKER_NODE_MODULES_BIN_PATH"] ||= File.join(`pnpm root`.chomp, ".bin")

    Rails::Engine.class_eval do
      alias_method :unfiltered_tasks, :load_tasks

      # hook into generic task loading to remove special yarn install task
      def load_tasks(_app = self)
        unfiltered_tasks
        Rake::Task["yarn:install"].clear
      end

      protected

      # We have to make sure that the original Webpacker tasks do not load
      # because most of them assume we are running in a Yarn environment. To
      # make the pnpm integration as seamless as possible, add a condition
      # to the engine task loader so users don't have to include annoying
      # task override code to their Rakefiles
      def run_tasks_blocks(*)
        super

        paths["lib/tasks"].existent.sort.each do |ext|
          # do not load if its a default webpacker task
          load(ext) unless ext.include?("webpacker") && !ext.include?("pnpm")
        end
      end
    end
  end
end
