import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import '@fortawesome/fontawesome-free/js/all';
import Vue from 'vue/dist/vue.esm'
import TurbolinksAdapter from 'vue-turbolinks'

Vue.use(TurbolinksAdapter)

Rails.start()
Turbolinks.start()
ActiveStorage.start()
