require "spec"
require "../src/CrSerializer"
require "./spec_models"

Spec.before_each { CrSerializer.version = nil }
