# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Technology, type: :model do
  let(:user) { create :user_admin }
  let(:technology) { build :technology_family }

  context 'has validations on' do
    let(:no_name) { build :technology_family, name: nil }
    let(:no_short_name) { build :technology_family, short_name: nil }
    let(:no_default_impact) { build :technology_family, default_impact: nil }
    let(:no_agreement_required) { build :technology_family, agreement_required: nil }
    let(:no_scale) { build :technology_family, scale: nil }
    let(:bad_scale) { build :technology_family, scale: 'small' }
    let(:no_report_worthy) { build :technology_family, report_worthy: nil }
    let(:no_dashboard_worthy) { build :technology_family, dashboard_worthy: nil }

    it 'name' do
      no_name.valid?
      expect(no_name.errors[:name]).to match_array("can't be blank")

      no_name.name = 'has a name'
      no_name.valid?
      expect(no_name.errors.any?).to eq false
    end

    it 'short_name' do
      no_short_name.valid?
      expect(no_short_name.errors[:short_name]).to match_array("can't be blank")

      no_short_name.short_name = 'has a name'
      no_short_name.valid?
      expect(no_short_name.errors.any?).to eq false
    end

    it 'default_impact' do
      no_default_impact.valid?
      expect(no_default_impact.errors[:default_impact]).to match_array("can't be blank")

      no_default_impact.default_impact = 1
      no_default_impact.valid?
      expect(no_default_impact.errors.any?).to eq false
    end

    it 'agreement_required' do
      no_agreement_required.valid?
      expect(no_agreement_required.errors[:agreement_required][0]).to include('is not included in the list')

      no_agreement_required.agreement_required = true
      expect(no_agreement_required.valid?).to eq true

      no_agreement_required.agreement_required = false
      expect(no_agreement_required.valid?).to eq true
    end

    it 'report_worthy' do
      no_report_worthy.valid?
      expect(no_report_worthy.errors[:report_worthy][0]).to include('is not included in the list')

      no_report_worthy.report_worthy = true
      expect(no_report_worthy.valid?).to eq true
      no_report_worthy.report_worthy = false
      expect(no_report_worthy.valid?).to eq true
    end

    it 'dashboard_worthy' do
      no_dashboard_worthy.valid?
      expect(no_dashboard_worthy.errors[:dashboard_worthy][0]).to include('is not included in the list')

      no_dashboard_worthy.dashboard_worthy = true
      expect(no_dashboard_worthy.valid?).to eq true
      no_dashboard_worthy.dashboard_worthy = false
      expect(no_dashboard_worthy.valid?).to eq true
    end

    it 'scale' do
      no_scale.valid?
      expect(no_scale.errors[:scale][0]).to include('Must be one of these:')

      bad_scale.valid?
      expect(bad_scale.errors[:scale][0]).to include('Must be one of these:')
    end
  end

  describe 'has scopes for' do
    context '#report_worthy' do
      let(:report_worthy) { create :technology_family, report_worthy: true }
      let(:not_report_worthy) { create :technology_family, report_worthy: false }

      it 'returns only Technology where report_worthy is true' do
        expect(Technology.report_worthy).to include report_worthy
        expect(Technology.report_worthy).not_to include not_report_worthy
      end
    end

    context '#not_engagement' do
      let(:engagement) { create :technology_engagement }
      let(:not_engagement) { create :technology_family }

      it 'returns only Technology where is_engagement is false' do
        expect(Technology.not_engagement).to include not_engagement
        expect(Technology.not_engagement).not_to include engagement
      end
    end

    context '#dashboard_worthy' do
      let(:dashboard_worthy) { create :technology_family, dashboard_worthy: true }
      let(:not_dashboard_worthy) { create :technology_family, dashboard_worthy: false }

      it 'returns only Technology where dashboard_worthy is true' do
        expect(Technology.dashboard_worthy).to include dashboard_worthy
        expect(Technology.dashboard_worthy).not_to include not_dashboard_worthy
      end
    end
  end

  describe '#default_household_impact' do
    it 'returns an integer that divides the default_impact by the HOUSEHOLD_SIZE constant' do
      # HOUSEHOLD_SIZE = 5
      technology.update(default_impact: 10)

      expect(technology.default_household_impact).to eq 2
    end
  end

  describe '#lifetime_impact' do
    let!(:technology) { create :technology }
    let(:contract)    { create :contract }
    let!(:report)     { create :report_facility, user: user, contract: contract, technology: technology, people: 10 }

    it 'returns the sum of related reports\' impact values' do
      expect(technology.reload.lifetime_impact).to eq(10)
    end

    context 'when no reports exist' do
      before { technology.reports.last.destroy }

      it 'equals 0' do
        expect(technology.reload.lifetime_impact).to eq(0)
      end
    end
  end

  describe '#liftime_distributed' do
    let!(:technology) { create :technology }
    let(:contract)    { create :contract }
    let!(:report)     { create :report_facility, user: user, contract: contract, technology: technology, people: 10 }

    it 'returns the sum of related reports\' distributed values' do
      expect(technology.reload.lifetime_distributed).to eq(1)
    end

    context 'when no reports exist' do
      before { technology.reports.last.destroy }

      it 'equals 0' do
        expect(technology.reload.lifetime_distributed).to eq(0)
      end
    end
  end

  describe '#plural_name' do
    let(:tech_engagement) { build :technology_engagement }

    context 'when Technology.is_engagement? is true' do
      it 'returns the technology name appended with "hours"' do
        expect(tech_engagement.plural_name).to eq "#{tech_engagement.name} hours"
      end
    end

    context 'when Technology.is_engagement? is false' do
      it 'returns the plural of the technology name' do
        expect(technology.plural_name).to eq technology.name.pluralize
      end
    end
  end

  describe '#type' do
    let(:tech_engagement) { build :technology_engagement }

    context 'when Technology.is_engagement? is true' do
      it 'returns "engagement"' do
        expect(tech_engagement.type).to eq 'engagement'
      end
    end

    context 'when Technology.is_engagement? is false' do
      it 'returns the scale attribute downcased' do
        expect(technology.type).to eq technology.scale.downcase
      end
    end
  end

  describe '#type_for_form' do
    let(:tech_community) { build :technology_community }

    context 'when Technology.scale == "Community"' do
      it 'returns "facility"' do
        expect(tech_community.type_for_form).to eq 'facility'
      end
    end

    context 'when Technology.scale != "Community"' do
      it 'returns "village"' do
        expect(technology.type_for_form).to eq 'village'
      end
    end
  end

  private

  describe '#community_engagement_is_family_scale' do
    context 'when is_engagement is true and scale == "Community"' do
      let(:tech_community) { build :technology_community, is_engagement: true }

      it 'fires on before_save' do
        expect(tech_community).to receive(:community_engagement_is_family_scale).exactly(1).times

        tech_community.save
      end

      it 'sets the scale to family' do
        expect { tech_community.save }.to change { tech_community.scale }.from('Community').to('Family')
      end
    end

    context 'when is_engagement is false and scale == "Community"' do
      let(:tech_community) { build :technology_community, is_engagement: false }

      it 'doesn\'t fire' do
        expect(tech_community).not_to receive(:community_engagement_is_family_scale)

        tech_community.save
      end
    end

    context 'when is_engagement is true and scale != "Community"' do
      it 'doesn\'t fire' do
        technology.is_engagement = true

        expect(technology).not_to receive(:community_engagement_is_family_scale)

        technology.save
      end
    end

    context 'when is_engagement is false and scale != "Community"' do
      it 'doesn\'t fire' do
        expect(technology).not_to receive(:community_engagement_is_family_scale)

        technology.save
      end
    end
  end
end
