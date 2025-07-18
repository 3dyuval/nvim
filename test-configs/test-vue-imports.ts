// Test Vue import ordering

import React, { useState } from 'react';
import { defineComponent, ref } from 'vue';
import VueRouter from 'vue-router';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { SelectMonthComponent } from '@/components/select-month/select-month.component';
import { AutomationApi } from '@/services/automation/automation-api.service';

export default defineComponent({
	name: 'TestComponent',
	setup() {
		const count = ref(0);
		return { count };
	}
});
