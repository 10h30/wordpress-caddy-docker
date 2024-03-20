SERVER_NAME=$(sed -e 's#.*=\(\)#\1#' <<< "$(awk '/SERVER_NAME/{print}' .env)" | xargs)
WORDPRESS_TITLE=$(sed -e 's#.*=\(\)#\1#' <<< "$(awk '/WORDPRESS_TITLE/{print}' .env)" | xargs)
WORDPRESS_USER=$(sed -e 's#.*=\(\)#\1#' <<< "$(awk '/WORDPRESS_ADMIN_USER/{print}' .env)" | xargs)
WORDPRESS_EMAIL=$(sed -e 's#.*=\(\)#\1#' <<< "$(awk '/WORDPRESS_ADMIN_EMAIL/{print}' .env)" | xargs)
WORDPRESS_PASSWORD=$(sed -e 's#.*=\(\)#\1#' <<< "$(awk '/WORDPRESS_ADMIN_PASSWORD/{print}' .env)" | xargs)
WORDPRESS_PLUGINS_TO_INSTALL=$(sed -e 's#.*=\(\)#\1#' <<< "$(awk '/WORDPRESS_PLUGINS_TO_INSTALL/{print}' .env)" | xargs)
WORDPRESS_THEME_TO_INSTALL=$(sed -e 's#.*=\(\)#\1#' <<< "$(awk '/WORDPRESS_THEME_TO_INSTALL/{print}' .env)" | xargs)

# Function to ask for yes/no confirmation
ask_yes_no() {
    QUESTION=$1
    while true; do
        # Customize your prompt message here
        read -p "$QUESTION" answer
        # Default to Yes if no answer is given
        if [[ -z "$answer" ]]; then
            answer="Y"
        fi

        case $answer in
            [Yy]* ) ANSWER=true; break;;
            [Nn]* ) ANSWER=false;break;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}



if ! docker compose run wpcli core is-installed ; then
	## Install Wodpress
    echo "== Installing WordPress =="
	docker compose run wpcli core install \
		--url=${SERVER_NAME} \
		--title="${WORDPRESS_TITLE}" \
		--admin_user=${WORDPRESS_USER} \
		--admin_email=${WORDPRESS_EMAIL} \
		--admin_password=${WORDPRESS_PASSWORD} \
		--skip-email

    ## Configure Permalinks
	echo "== Configure Permalinks =="
	docker compose run wpcli rewrite structure '/%postname%/'

    ## Install Plugins
    ask_yes_no "Do you want to install recommended plugins? [Y/n]"
    DOIT=$ANSWER
    if [ "$DOIT" = true ]; then
        echo "== Install Plugins =="
        
        docker compose run wpcli plugin install ${WORDPRESS_PLUGINS_TO_INSTALL} --activate

        ## Enable Redis Cache Object
        #docker compose run wpcli redis enable

        ## Enable and config Cache Enabler
        docker compose run wpcli option update cache_enabler '{
            "version": "1.8.0",
            "use_trailing_slashes": 1,
            "permalink_structure": "has_trailing_slash",
            "cache_expires": 1,
            "cache_expiry_time": 8,
            "clear_site_cache_on_saved_post": 0,
            "clear_site_cache_on_saved_comment": 0,
            "clear_site_cache_on_saved_term": 0,
            "clear_site_cache_on_saved_user": 0,
            "clear_site_cache_on_changed_plugin": 0,
            "convert_image_urls_to_webp": 0,
            "mobile_cache": 0,
            "compress_cache": 1,
            "minify_html": 1,
            "minify_inline_css_js": 1,
            "excluded_post_ids": "",
            "excluded_page_paths": "",
            "excluded_query_strings": "",
            "excluded_cookies": ""
        }' --format=json
    fi

    # Theme installation
    ask_yes_no "Do you want to install recommended theme? [Y/n]"
    DOIT=$ANSWER
    if [ "$DOIT" = true ]; then
        echo "== Installing themes =="
        docker compose run wpcli theme install "${WORDPRESS_THEME_TO_INSTALL}" --activate
    fi


    echo -e "\nREPORT\n"

    # List users
    echo "== User List =="
    docker compose run wpcli user list
    echo ""

    # Show installed plugin
    echo "== Theme List =="
    docker compose run wpcli theme list
    echo ""

    # Show installed plugin
    echo "== Plugin List =="
    docker compose run wpcli plugin list
    echo ""
else
	echo "WordPress is already installed. Exiting now..."
fi
