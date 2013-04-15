require 'spec_helper'
include ApplicationHelper

describe "Groups" do
  describe "get while not logged in" do
    before { visit groups_path }
    it { page.should redirect_to_signin }
  end
end

describe "Groups" do
  let(:user) { FactoryGirl.create(:user) }
  before {sign_in user}

  describe "get root" do
    let!(:group) { FactoryGirl.create(:group_with_volunteer) }
    let!(:attached_vol) { group.volunteers.first }
    let!(:volunteer) { FactoryGirl.create(:volunteer) }
    before { visit groups_path }

    subject { page } 

    it { should_not redirect_to_signin }
    it { subject.status_code.should be(200) }
   
    it { find('title').text.should eq full_title('Groups') }  

    context "add form" do
      it { should have_selector('#group_name') }
      it { should have_selector('#group_email') }
      it { should have_selector('input', type: 'submit', name: 'commit', value: 'Add Group') }
    end

    context "volunteer table" do
      it { should have_selector('legend', text: 'Groups') }
      it { find('table/tr[1]/th[1]').text.should eq 'Name' }
      it { find('table/tr[1]/th[2]').text.should eq 'Email' }
      it { find('table/tr[1]/th[3]').text.should eq 'Rotation' }
      it { find('table/tr[1]/th[4]').text.should eq '' }
      it { find('table/tr[1]/th[5]').text.should eq '' }
      it { find('table/tr[1]/th[6]').text.should eq '' }
      it { find('table/tr[1]/th[7]').text.should eq '' }
      it { find('table/tr[1]/th[8]').text.should eq '' }
      it { should_not have_selector('table/tr[1]/th[9]') }

      it { find('table/tr[2]/td[1]').text.should eq group.name }
      it { find('table/tr[2]/td[2]').text.should eq group.email }
      it { find('table/tr[2]/td[3]').text.should eq group.rotation?.to_s }
      it { find('table/tr[2]/td[4]').text.strip.should eq 'edit' }
      it { find('table/tr[2]/td[5]').text.should eq 'volunteers' }
      it { find('table/tr[2]/td[6]').text.should eq 'export' }
      it { find('table/tr[2]/td[7]').text.should eq '' }
      it { find('table/tr[2]/td[8]').text.strip.should eq 'remove' }
      it { should_not have_selector('table/tr[2]/td[9]') }
    end

    context "add group" do
      it "with correct data" do 
        fill_in "Name", with: "Test Group"
        fill_in "Email", with: "testgroup@example.com"
        click_button "Add Group"
        current_path.should eq groups_path
        should have_selector('table/tr', count:3)
        find('table/tr[3]/td[1]').text.should eq "Test Group"
        find('table/tr[3]/td[2]').text.should eq 'testgroup@example.com'
        find('table/tr[3]/td[3]').text.should eq false.to_s 
      end

      it "with blank data" do
        click_button "Add Group"
        current_path.should eq groups_path
        should have_selector('table/tr', count:2)
        should have_error_message "See errors below"
        should have_error_message "Name can't be blank"
        should have_error_message "Email can't be blank"
        should have_error_message "Email is invalid"
      end

      it "with invalid email" do
        fill_in "Name", with: "Test Group"
        fill_in "Email", with: "testgroup@example."
        click_button "Add Group"
        current_path.should eq groups_path
        should have_error_message "See errors below"
        should have_error_message "Email is invalid"
        should_not have_error_message "Email can't be blank"
        should_not have_error_message "Name"
      end

      it "edit" do
        edit_link = find('table/tr[2]/td[4]/a')
        edit_link.text.should eq 'edit'
        edit_link.click
        current_path = edit_group_path(group.id)
        find('#group_name').value.should eq group.name
        find('#group_email').value.should eq group.email
        find('#group_rotation').should_not be_checked
        find('#group_email_body').text.should eq ''
        fill_in "Name", with: "Name Change"
        fill_in "Email", with: "namechange@example.com"
        check "has a rotation?"
        fill_in "Email body", with: "<%=this_week%> <%=this_week_vols%>"
        click_button "Save changes"
        find('table/tr[2]/td[1]').text.should eq 'Name Change'
        find('table/tr[2]/td[2]').text.should eq 'namechange@example.com'
        find('table/tr[2]/td[3]').text.should eq true.to_s

        edit_link = find('table/tr[2]/td[4]/a')
        edit_link.click
        find('#group_name').value.should eq "Name Change" 
        find('#group_email').value.should eq "namechange@example.com" 
        find('#group_rotation').should be_checked
        find('#group_email_body').text.strip.should eq '<%=this_week%> <%=this_week_vols%>'
      end
    end
    context "view volunteers" do
      it "go to edit" do
        vols_link = find('table/tr[2]/td[5]/a')
        vols_link.text.should eq 'volunteers'
        vols_link.click
        current_path = volunteers_group_path(group.id)

        find('#volunteers_table/tr[1]/th[1]').text.should eq 'Name' 
        find('#volunteers_table/tr[1]/th[2]').text.should eq 'Email' 
        find('#volunteers_table/tr[1]/th[3]').text.should eq '' 
        should have_no_selector('#volunteers_table/tr[1]/th[4]')
        find('#volunteers_table/tr[2]/td[1]').text.should eq attached_vol.full_name
        find('#volunteers_table/tr[2]/td[2]').text.should eq attached_vol.email
        find('#volunteers_table/tr[2]/td[3]').text.should eq 'remove' 
        should have_no_selector('#volunteers_table/tr[2]/td[4]')

        find('#available_volunteers_table/tr[1]/th[1]').text.should eq 'Name'
        find('#available_volunteers_table/tr[1]/th[2]').text.should eq 'Email'
        find('#available_volunteers_table/tr[1]/th[3]').text.should eq ''
        should have_no_selector('#available_volunteers_table/tr[1]/th[4]')
        find('#available_volunteers_table/tr[2]/td[1]').text.should eq volunteer.full_name
        find('#available_volunteers_table/tr[2]/td[2]').text.should eq volunteer.email
        find('#available_volunteers_table/tr[2]/td[3]').text.should eq 'add' 
        should have_no_selector('#available_volunteers_table/tr[2]/td[4]')
      end

      it "remove volunteer" do
        visit volunteers_group_path(group.id)

        find('#volunteers_table/tr[2]/td[1]').text.should eq attached_vol.full_name
        find('#volunteers_table/tr[2]/td[2]').text.should eq attached_vol.email

        remove_link = find('#volunteers_table/tr[2]/td[3]/a')
        remove_link.text.should eq 'remove' 
        remove_link.click
        current_path.should eq volunteers_group_path(group.id)
        should have_success_message "#{attached_vol.full_name} removed."
      end
    end
  end
end
