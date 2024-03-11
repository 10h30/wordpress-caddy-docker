# wordpress-caddy-docker
 A docker-composed based platform for running WordPress with Caddy server V2

## 🏃 Getting Started

To get your WordPress installation running follow these simple steps.

### Prerequisites

* [Docker](https://www.docker.com/)
* [Docker Compose](https://docs.docker.com/compose/)


### Installation

1. Clone the repo
   ```sh
   git clone https://github.com/10h30/wordpress-caddy-docker.git
   ```
2. Go into the created folder
   ```sh
   cd ./wordpress-caddy-docker
   find . -type f -iname "*.sh" -exec chmod +x {} \;
   ```

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- USAGE EXAMPLES -->
## 🚀 Usage

### Install

1. Modify passwords and variables inside ```.env``` file as you wish
2. Run shell command
   ```sh
   sh wp-install.sh
   ```
### Init Wordpress Installation

1. Run shell command
   ```sh
   sh wp-init.sh
   ```

### Uninstall

1. Run shell command
   ```sh
   sh wp-uninstall.sh
   ```
