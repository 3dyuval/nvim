<!--
drill: repeat patterns — 2026-10-18
subject: f/t/F/T find-repeat (; ,) vs change-repeat (.)
augment: cr"NEW keeps the quotes (t=around would delete them in this layout)

- [ ] TODO: §1 f{ then ; ; , → (should jump to each opening brace, then walk back)
- [ ] TODO: §2 t, then ; ; → (should stop just before each comma, one at a time)
- [ ] TODO: §3 edit name up to =, then . down the lines → (should repeat the same edit)
- [ ] TODO: §4 change a word to foo, then . → (should repeat the change word by word)
- [ ] TODO: §5 cr"NEW inside each string → (should replace the text, keeping the quotes)
-->
<script setup lang="ts">
import { ref, computed } from 'vue'

// §1
const a = { x: { y: { z: 1 } } }



// §2
const nums = [10, 20, 30, 40, 50]



// §3
const alpha = ref(1)
const beta  = ref(2)
const gamma = ref(3)



// §4
const dog = 1
const cat = 2
const owl = 3



// §5
const labels = ["one", "two", "three"]
</script>
