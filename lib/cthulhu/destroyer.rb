module Cthulhu
  class Destroyer

    attr_reader :root, :root_klass, :option_overrides, :blacklisted
    attr_accessor :skip

    def initialize root, blacklisted = [], not_to_be_crawled = [], option_overrides = {}
      @root = root
      @root_klass = root.class
      @skip = not_to_be_crawled.to_set
      @option_overrides = option_overrides
      @blacklisted = blacklisted
    end

    def destroy!
      crawl root.class, [root.class]
    end

  private

    def crawl crawling, chained_classes, chain = [], inverse_chain = []
      has_and_belongs_to_many_usages = []

      return if blacklisted.include? crawling
      added = !skip.include?(crawling)
      key = [chained_classes.second, crawling].compact.join('-')
      return if skip.include? key
      skip.add key

      nullify = {}

      crawling.reflections.each do |name, association|
        if association.is_a?(ActiveRecord::Reflection::HasAndBelongsToManyReflection)
          has_and_belongs_to_many_usages << name
          next
        end
        if !association.is_a?(ActiveRecord::Reflection::HasManyReflection) &&
          !association.is_a?(ActiveRecord::Reflection::HasOneReflection) &&
          next
        end
        next unless association.through_reflection.nil?
        klass = association.klass rescue Object
        next unless klass < ActiveRecord::Base

        tmp_chain = chain.map do |link|
          link.to_s.singularize
        end
        tmp_inverse_chain = inverse_chain.dup
        tmp_chained_classes = chained_classes.dup

        inverse_of = inverse_name_of association
        if inverse_of.blank?
          raise UncrawlableHierarchy,
            "You need to set inverse_of for #{crawling}.#{name} association"
        end
        inverse_association = klass.reflections[inverse_of]
        name_according_to_inverse = inverse_name_of inverse_association, name
        if name_according_to_inverse.blank?
          raise UncrawlableHierarchy,
            "You need to set inverse_of for #{klass}.#{inverse_of} association"
        end

        singularized_inverse_of = inverse_of.singularize
        if tmp_chain.first != singularized_inverse_of
          tmp_chain.unshift singularized_inverse_of
          tmp_inverse_chain << name
          tmp_chained_classes.unshift klass
        end

        if option(association, :dependent) == :nullify
          nullify[name] = [klass, tmp_chained_classes, tmp_chain, tmp_inverse_chain]
          next
        end

        crawl klass, tmp_chained_classes, tmp_chain, tmp_inverse_chain
      end

      Scopper.new(
        root,
        crawling,
        chained_classes,
        chain,
        inverse_chain,
        has_and_belongs_to_many_usages,
        nullify
      ).delete!
    end

    def inverse_name_of association, default = nil
      (
        direct_inverse_of(association) ||
        option_inverse_of(association) ||
        default
      ).to_s
    end

    def direct_inverse_of association
      association.inverse_of.try(:name) rescue nil
    end

    def option_inverse_of association
      option association, :inverse_of rescue nil
    end

    def option association, name
      override = option_overrides[association.active_record].
        try(:[], association.name).
        try(:[], name)
      override || association.options[name]
    end

  end
end
