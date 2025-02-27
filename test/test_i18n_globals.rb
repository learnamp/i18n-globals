require 'minitest/autorun'
require 'minitest/pride'
require 'i18n-globals'

# rubocop:disable Metrics/ClassLength
class TestI18nGlobals < Minitest::Test
  def setup
    I18n.backend.load_translations 'test/fixtures/translations.yml'
    I18n.config.globals = {}
  end

  def test_that_simple_translations_work
    assert_equal 'Hello World!', I18n.translate('test')
  end

  def test_that_interpolated_variables_work
    assert_equal 'Hi there, Joe!', I18n.translate('greeting', name: 'Joe')
  end

  def test_that_global_variables_work
    I18n.config.globals[:name] = 'Bill'

    assert_equal 'Hi there, Bill!', I18n.translate('greeting')
  end

  def test_that_global_variables_can_be_overwritten
    I18n.config.globals[:name] = 'Nick'

    assert_equal 'Hi there, Nick!', I18n.translate('greeting', name: 'Nick')
  end

  def test_that_multiple_global_variables_work
    I18n.config.globals[:name] = 'Chell'
    I18n.config.globals[:company] = 'Aperture Science'

    assert_equal 'Hello Chell, welcome to Aperture Science!', I18n.translate('welcome')
  end

  def test_that_one_of_the_global_variables_can_be_overwritten
    I18n.config.globals[:name] = 'Barney'
    I18n.config.globals[:company] = 'Black Mesa'

    assert_equal 'Hello Barney, welcome to Black Mesa!', I18n.translate('welcome', name: 'Barney')
  end

  def test_that_the_other_global_variable_can_be_overwritten
    I18n.config.globals[:name] = 'Barney'
    I18n.config.globals[:company] = 'Black Mesa'

    assert_equal 'Hello Barney, welcome to Black Mesa!',
                 I18n.translate('welcome', company: 'Black Mesa')
  end

  def test_that_all_of_the_global_variables_can_be_overwritten
    I18n.config.globals[:name] = 'Barney'
    I18n.config.globals[:company] = 'Black Mesa'

    assert_equal 'Hello Barney, welcome to Black Mesa!',
                 I18n.translate('welcome', name: 'Barney', company: 'Black Mesa')
  end

  def test_that_the_t_alias_work
    I18n.config.globals[:name] = 'Chell'
    I18n.config.globals[:company] = 'Aperture Science'

    assert_equal 'Hello Chell, welcome to Aperture Science!', I18n.t('welcome')
  end

  def test_that_global_variables_are_shared_between_config_instances
    I18n.config.globals[:name] = 'Greg'

    I18n.config = I18n::Config.new

    assert_equal 'Hi there, Greg!', I18n.translate('greeting')
  end

  def test_that_locale_dependent_variable_overrides_default_one
    I18n.config.globals = {
      name: 'Greg',
      en: { name: 'Debby' }
    }

    assert_equal 'Hi there, Greg!', I18n.translate('greeting')
  end

  def test_that_default_variable_is_used_if_no_special_locale_version_is_present
    I18n.config.globals = {
      name: 'Greg',
      fr: { name: 'Debora' }
    }

    assert_equal 'Hi there, Greg!', I18n.translate('greeting')
  end

  def test_that_cache_is_cleared_after_setting_a_new_locale_global
    I18n.config.globals = {
      name: 'Greg',
    }

    assert_equal 'Hi there, Greg!', I18n.translate('greeting')

    I18n.config.globals[:name] = 'Elisa'

    assert_equal 'Hi there, Elisa!', I18n.translate('greeting')
  end

  def test_that_cache_is_cleared_after_setting_a_new_locale_hash
    I18n.config.globals = {
      name: 'Greg'
    }

    assert_equal 'Hi there, Greg!', I18n.translate('greeting')

    I18n.config.globals = {
      name: 'Elisa'
    }

    assert_equal 'Hi there, Elisa!', I18n.translate('greeting')
  end

  def test_that_cache_is_cleared_after_merging_a_new_locale_hash
    I18n.config.globals = {
      name: 'Greg'
    }

    assert_equal 'Hi there, Greg!', I18n.translate('greeting')

    I18n.config.globals.merge!(name: 'Elisa') # rubocop:disable Performance/RedundantMerge

    assert_equal 'Hi there, Elisa!', I18n.translate('greeting')
  end

  def test_that_cache_is_cleared_after_clearing_locale_hash
    I18n.config.globals = {
      name: 'Greg',
      en: { name: 'Debby' }
    }

    assert_equal 'Hi there, Greg!', I18n.translate('greeting')

    I18n.config.globals[:en].clear

    assert_equal 'Hi there, Greg!', I18n.translate('greeting')
  end

  def test_that_cache_is_cleared_after_setting_a_new_global
    I18n.config.globals[:name] = 'Greg'

    assert_equal 'Hi there, Greg!', I18n.translate('greeting')

    I18n.config.globals[:name] = 'Dobby'

    assert_equal 'Hi there, Dobby!', I18n.translate('greeting')
  end

  def test_that_cache_is_cleared_after_merging_a_new_global
    I18n.config.globals[:name] = 'Greg'

    assert_equal 'Hi there, Greg!', I18n.translate('greeting')

    I18n.config.globals.merge!(name: 'Dobby') # rubocop:disable Performance/RedundantMerge

    assert_equal 'Hi there, Dobby!', I18n.translate('greeting')
  end

  def test_that_it_still_fails_on_missing_interpolation
    assert_raises(I18n::MissingInterpolationArgument) { I18n.translate('greeting', foo: 'bar') }
  end

  def test_that_it_allows_to_set_a_custom_missing_interpolation_argument_handler
    I18n.config.missing_interpolation_argument_handler = -> { raise 'works!' }

    assert_raises('works!') { I18n.translate('greeting', foo: 'bar') }

    I18n.config.missing_interpolation_argument_handler = nil
  end

  def test_that_it_translates_globals_with_custom_missing_interpolation_argument_handler
    I18n.config.missing_interpolation_argument_handler = -> { raise 'works!' }

    I18n.config.globals[:name] = 'Greg'

    assert_equal 'Hi there, Greg!', I18n.translate('greeting')

    I18n.config.missing_interpolation_argument_handler = nil
  end
end
# rubocop:enable Metrics/ClassLength
