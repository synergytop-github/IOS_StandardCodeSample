public function create_campaign($ajax = '') {
        if ($this->input->post()) {
            $user_id = $this->session->userdata('user_id');
            $formdata = $this->input->post();
            $campaign_data = array(
                'ucm_fk_uc_id' => $user_id,
                'ucm_title' => $formdata['campaign_name'],
                'ucm_headline' => $formdata['headline'],
                'ucm_description' => $formdata['description'],
                'ucm_type' => 'Personal Campaign',
                'ucm_accept_donations' => '0',
                'ucm_social_share' => '0',
                'ucm_enable_campaign_updating' => '0',
                'ucm_enable_comments' => '0',
                'ucm_show_donations_leaderboard' => '0',
                'ucm_show_top_advisor_leaderboard' => '0',
                'ucm_show_stats' => '0',
                'ucm_show_campaigns' => '0',
                'ucm_created' => date('Y-m-d H:i:s'),
                'ucm_home_page' => '0',
                'ucm_show_media' => '1',
                'ucm_show_video' => '1',
                'ucm_show_image' => '1',
                'ucm_show_tag' => '0',
                'ucm_show_success_trek_speaking_video' => '1',
                'ucm_speaking_video_autoplay' => '1'
            );
            $campaign_data['ucm_color'] = $this->input->post('color');
            if ($this->input->post('home_page')) {
                $campaign_data['ucm_home_page'] = '1';
                $home_page['ucm_home_page'] = 0;
                $this->library->update('user_campaign', $home_page, array('ucm_fk_uc_id' => $user_id, 'ucm_home_page' => 1));
            }
            if ($this->input->post('campaign_type')) {
                $campaign_data['ucm_type'] = $this->input->post('campaign_type');
            }
            if ($this->input->post('donation')) {
                $campaign_data['ucm_accept_donations'] = $this->input->post('donation');
            }
            if ($this->input->post('share')) {
                $campaign_data['ucm_social_share'] = $this->input->post('share');
            }
            if ($this->input->post('update')) {
                $campaign_data['ucm_enable_campaign_updating'] = $this->input->post('update');
            }
            if ($this->input->post('comment')) {
                $campaign_data['ucm_enable_comments'] = $this->input->post('comment');
            }
            if ($this->input->post('donation_list')) {
                $campaign_data['ucm_show_donations_leaderboard'] = $this->input->post('donation_list');
            }
            if ($this->input->post('advisor_list')) {
                $campaign_data['ucm_show_top_advisor_leaderboard'] = $this->input->post('advisor_list');
            }
            if ($this->input->post('stat')) {
                $campaign_data['ucm_show_stats'] = $this->input->post('stat');
            }
            if ($this->input->post('campaign')) {
                $campaign_data['ucm_show_campaigns'] = $this->input->post('campaign');
            }
            if ($this->input->post('show_media')) {
                $campaign_data['ucm_show_media'] = $this->input->post('show_media');
            }
            if ($this->input->post('show_image')) {
                $campaign_data['ucm_show_image'] = $this->input->post('show_image');
            }
            if ($this->input->post('show_video')) {
                $campaign_data['ucm_show_video'] = $this->input->post('show_video');
            }
            if ($this->input->post('show_speaking_video')) {
                $campaign_data['ucm_show_success_trek_speaking_video'] = $this->input->post('show_speaking_video');
            }
            if ((isset($formdata['autoplay']) == false)) {
                $campaign_data['ucm_speaking_video_autoplay '] = '0';
            }
            if ($this->input->post('show_tag')) {
                $campaign_data['ucm_show_tag'] = '1';
            }
            if ($formdata['publish']) {
                $campaign_data['ucm_publish'] = '1';
            } else {
                $campaign_data['ucm_publish'] = '0';
            }
            $id = $this->library->insert('user_campaign', $campaign_data);
            if ($_FILES['campaign_logo']) {
                if ($_FILES['campaign_logo']['name']) {
                    $this->campaign_logo($id, $_FILES['campaign_logo']);
                }
            }
            if ($_FILES['campaign_image']) {
                if ($_FILES['campaign_image']['name']) {
                    $this->campaign_main_image($id, $_FILES['campaign_image']);
                }
            }
            if (isset($_FILES['image'])) {
                $this->campaign_image($id, $_FILES['image'], $this->input->post('image_id'));
            }
            if ($_FILES['campaign_main_logo']) {
                if ($_FILES['campaign_main_logo']['name']) {
                    $this->campaign_main_logo($id, $_FILES['campaign_main_logo']);
                }
            }
            if ($this->input->post('cause_percent') && $this->input->post('campaign_type') == 'Charity Campaign') {
                $this->add_campaign_non_profit_organization($id, $this->input->post('cause_id'), $this->input->post('cause_percent'));
            }
            if ($this->input->post('mute_video')) {
                $this->campaign_mute_video($id, $this->input->post('mute_video'), $this->input->post('mute_video_id'));
            }
            if ($this->input->post('speaking_video')) {
                $this->campaign_speaking_video($id, $this->input->post('speaking_video'), $this->input->post('speaking_video_id'));
            }
            if ($this->input->post('tag')) {
                $this->add_tag($id, $this->input->post());
            }
            if ($this->input->post('lunch_with')) {
                $this->add_lunch($id, $this->input->post('lunch_with'));
            }
            if ($this->input->post('section_id')) {
                $this->campaign_section($id, $this->input->post());
            }
            $user_campaign_history['uch_fk_ucm_id'] = $id;
            $user_campaign_history['uch_fk_uc_id'] = $user_id;
            $user_campaign_history['uch_started_date'] = date('c');
            $this->library->insert('user_campaign_history', $user_campaign_history);
            if ($ajax) {
                echo $this->library->base64_encode($id);
            } else {
                redirect(base_url('update-campaign/' . $this->library->base64_encode($id)));
            }
        }
    }

    public function update_campaign($ajax = '') {
        if ($this->input->post()) {
            $campaign = $this->library->selectOBj('user_campaign', 'ucm_id', array('ucm_id' => $this->input->post('campaign_id'), 'ucm_fk_uc_id' => $this->session->userdata('user_id')));
            if (count($campaign)) {
                $user_id = $this->session->userdata('user_id');
                $formdata = $this->input->post();
                $campaign_id = $formdata['campaign_id'];
                $campaign_detail = $this->library->selectObj('user_campaign', '', array('ucm_id' => $campaign_id, 'ucm_fk_uc_id' => $user_id));
                if (count($campaign_detail)) {
                    $campaign_data = array(
                        'ucm_title' => $formdata['campaign_name'],
                        'ucm_headline' => $formdata['headline'],
                        'ucm_description' => $formdata['description'],
                        'ucm_accept_donations' => '0',
                        'ucm_social_share' => '0',
                        'ucm_enable_campaign_updating' => '0',
                        'ucm_enable_comments' => '0',
                        'ucm_show_donations_leaderboard' => '0',
                        'ucm_show_top_advisor_leaderboard' => '0',
                        'ucm_show_stats' => '0',
                        'ucm_show_campaigns' => '0',
                        'ucm_created' => date('Y-m-d H:i:s'),
                        'ucm_home_page' => '0',
                        'ucm_show_media' => '1',
                        'ucm_show_video' => '1',
                        'ucm_show_image' => '1',
                        'ucm_show_tag' => '0',
                        'ucm_show_success_trek_speaking_video' => '1',
                        'ucm_speaking_video_autoplay' => '1'
                    );
                    $campaign_data['ucm_color'] = $this->input->post('color');
                    if ($this->input->post('home_page')) {
                        $campaign_data['ucm_home_page'] = '1';
                        $home_page['ucm_home_page'] = 0;
                        $this->library->update('user_campaign', $home_page, array('ucm_fk_uc_id' => $user_id, 'ucm_home_page' => 1));
                    }
                    if ($this->input->post('donation')) {
                        $campaign_data['ucm_accept_donations'] = $this->input->post('donation');
                    }
                    if ($this->input->post('share')) {
                        $campaign_data['ucm_social_share'] = $this->input->post('share');
                    }
                    if ($this->input->post('update')) {
                        $campaign_data['ucm_enable_campaign_updating'] = $this->input->post('update');
                    }
                    if ($this->input->post('comment')) {
                        $campaign_data['ucm_enable_comments'] = $this->input->post('comment');
                    }
                    if ($this->input->post('donation_list')) {
                        $campaign_data['ucm_show_donations_leaderboard'] = $this->input->post('donation_list');
                    }
                    if ($this->input->post('advisor_list')) {
                        $campaign_data['ucm_show_top_advisor_leaderboard'] = $this->input->post('advisor_list');
                    }
                    if ($this->input->post('stat')) {
                        $campaign_data['ucm_show_stats'] = $this->input->post('stat');
                    }
                    if ($this->input->post('campaign')) {
                        $campaign_data['ucm_show_campaigns'] = $this->input->post('campaign');
                    }
                    if ($this->input->post('show_media')) {
                        $campaign_data['ucm_show_media'] = $this->input->post('show_media');
                    }
                    if ($this->input->post('show_image')) {
                        $campaign_data['ucm_show_image'] = $this->input->post('show_image');
                    }
                    if ($this->input->post('show_video')) {
                        $campaign_data['ucm_show_video'] = $this->input->post('show_video');
                    }
                    if ($this->input->post('show_speaking_video')) {
                        $campaign_data['ucm_show_success_trek_speaking_video'] = $this->input->post('show_speaking_video');
                    }
                    if ((isset($formdata['autoplay']) == false)) {
                        $campaign_data['ucm_speaking_video_autoplay '] = '0';
                    }
                    if ($this->input->post('show_tag')) {
                        $campaign_data['ucm_show_tag'] = '1';
                    }
                    if ($campaign_detail->ucm_publish == 0) {
                        if ($formdata['publish']) {
                            $campaign_data['ucm_publish'] = '1';
                        } else {
                            $campaign_data['ucm_publish'] = '0';
                        }
                    }
                    $this->library->update('user_campaign', $campaign_data, array('ucm_id' => $this->input->post('campaign_id'), 'ucm_fk_uc_id' => $user_id));
                    $id = $this->input->post('campaign_id');
                    if ($_FILES['campaign_logo']) {
                        if ($_FILES['campaign_logo']['name']) {
                            $this->campaign_logo($id, $_FILES['campaign_logo']);
                        }
                    }
                    if ($_FILES['campaign_image']) {
                        if ($_FILES['campaign_image']['name']) {
                            $this->campaign_main_image($id, $_FILES['campaign_image']);
                        }
                    }
                    if ($_FILES['campaign_main_logo']) {
                        if ($_FILES['campaign_main_logo']['name']) {
                            $this->campaign_main_logo($id, $_FILES['campaign_main_logo']);
                        }
                    }
                    if ($this->input->post('cause_percent') && $this->input->post('campaign_type') == 'Charity Campaign') {
                        $this->add_campaign_non_profit_organization($id, $this->input->post('cause_id'), $this->input->post('cause_percent'));
                    }
                    if ($this->input->post('update_cause_percent') && $this->input->post('campaign_type') == 'Charity Campaign') {
                        $this->update_campaign_non_profit_organization($id, $this->input->post('update_cause_id'), $this->input->post('update_cause_percent'));
                    }
                    if (isset($_FILES['image'])) {
                        $this->campaign_image($id, $_FILES['image'], $this->input->post('image_id'));
                    }
                    if ($this->input->post('mute_video')) {
                        $this->campaign_mute_video($id, $this->input->post('mute_video'), $this->input->post('mute_video_id'));
                    }
                    if ($this->input->post('speaking_video')) {
                        $this->campaign_speaking_video($id, $this->input->post('speaking_video'), $this->input->post('speaking_video_id'));
                    }
                    if ($this->input->post('tag')) {
                        $this->add_tag($id, $this->input->post());
                    }
                    if ($this->input->post('lunch_with')) {
                        $this->add_lunch($id, $this->input->post('lunch_with'));
                    }
                    if ($this->input->post('section_id')) {
                        $this->campaign_section($id, $this->input->post());
                    }
                }
                if ($ajax) {
                    echo 'Update';
                } else {
                    redirect($_SERVER['HTTP_REFERER']);
                }
            } else {
                $this->session->set_userdata('popup_message', 'This is not an appropriate way to access the site');
                redirect($_SERVER['HTTP_REFERER']);
            }
        }
    }