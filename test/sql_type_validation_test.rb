require 'test_helper'
require 'validation_reflection'

class Blog < ActiveRecord::Base
end

class Category < ActiveRecord::Base
  sql_type_validation :name
end

class Entry < ActiveRecord::Base
  belongs_to :blog
  belongs_to :category
  validates_length_of :foo, :maximum => 5
  sql_type_validation columns
end

class SqlTypeValidationTest < ActiveSupport::TestCase
  test 'for Category#name' do
    refl = Category.reflect_on_validations_for(:name).detect do |i|
      i.macro == :validates_presence_of
    end

    assert_not_nil refl
  end

  test 'for Category#foo' do
    refl = Category.reflect_on_validations_for :foo
    assert !refl.map(&:macro).include?(:validates_presence_of)
  end

  test 'for foo : validation が二重に定義されないこと' do
    refl = Entry.reflect_on_validations_for(:foo).detect do |i|
      i.macro == :validates_length_of
    end

    assert_not_nil refl
    assert_equal({:maximum=>5}, refl.options)
  end

  test 'for allow_null_string' do
    refl = Entry.reflect_on_validations_for :allow_null_string
    assert !refl.map(&:macro).include?(:validates_presence_of)
  end

  test 'for not_null_string' do
    refl = Entry.reflect_on_validations_for(:not_null_string).detect do |i|
      i.macro == :validates_presence_of
    end

    assert_not_nil refl
    assert_equal({}, refl.options)
  end

  test 'for limit_10_string' do
    refl = Entry.reflect_on_validations_for(:limit_10_string).detect do |i|
      i.macro == :validates_length_of
    end

    assert_not_nil refl
    assert_equal({:allow_nil=>true, :maximum=>10}, refl.options)
  end

  test 'for not_null_limit_10_string' do
    refl = Entry.reflect_on_validations_for(:not_null_limit_10_string).detect do |i|
      i.macro == :validates_length_of
    end

    assert_not_nil refl
    assert_equal({:allow_nil=>false, :maximum=>10}, refl.options)
  end

  test 'for allow_null_integer' do
    refl = Entry.reflect_on_validations_for(:allow_null_integer)
    assert !refl.map(&:macro).include?(:validates_presence_of)
  end

  test 'for not_null_integer' do
    refl = Entry.reflect_on_validations_for(:not_null_integer).detect do |i|
      i.macro == :validates_presence_of
    end

    assert_not_nil refl
    assert_equal({}, refl.options)
  end

  test 'for limit_10_integer' do
    refl = Entry.reflect_on_validations_for(:limit_10_integer).detect do |i|
      i.macro == :validates_numericality_of
    end

    assert_not_nil refl
    assert_equal({:allow_nil=>true, :less_than=>10000000000}, refl.options)
  end

  test 'for not_null_limit_10_integer' do
    refl = Entry.reflect_on_validations_for(:not_null_limit_10_integer).detect do |i|
      i.macro == :validates_numericality_of
    end

    assert_not_nil refl
    assert_equal({:allow_nil=>false, :less_than=>10000000000}, refl.options)

    refl = Entry.reflect_on_validations_for(:not_null_limit_10_integer).detect do |i|
      i.macro == :validates_presence_of
    end

    assert_not_nil refl
  end

  test 'for association for blog' do
    refl = Entry.reflect_on_validations_for(:blog).detect do |i|
      i.macro == :validates_presence_of
    end

    assert_not_nil refl
    assert_equal({}, refl.options)
  end

  test 'for association for category' do
    refl = Entry.reflect_on_validations_for :category
    assert !refl.map(&:macro).include?(:validates_presence_of)
  end

  test 'for allow_null_boolean' do
    refl = Entry.reflect_on_validations_for :allow_null_boolean
    assert !refl.map(&:macro).include?(:validates_inclusion_of)
  end

  test 'for not_null_boolean' do
    refl = Entry.reflect_on_validations_for(:not_null_boolean).detect do |i|
      i.macro == :validates_inclusion_of
    end

    assert_not_nil refl
    assert_equal({:in=>[true, false]}, refl.options)
  end

  test 'for limit_100_text' do
    refl = Entry.reflect_on_validations_for(:limit_100_text).detect do |i|
      i.macro == :validates_length_of
    end

    assert_not_nil refl
    assert_equal({:allow_nil=>true, :maximum=>100}, refl.options)
  end
end
