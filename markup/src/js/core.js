import '@fancyapps/ui';
import {Fancybox} from "@fancyapps/ui";

import './include/jquery-code';

// custom
import {Opener} from "./block/opener";
import Photo from "./block/photo";

window.fbox = Fancybox;

new Opener();
new Photo();