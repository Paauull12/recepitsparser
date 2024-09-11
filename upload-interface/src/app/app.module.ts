import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { FileUploadComponent } from './module/file-upload/file-upload.component';
import { LDSFileUpload } from '@luminess/design-system/file-upload';
import { LDSTable } from '@luminess/design-system/table';
import { DentalQuoteComponent } from './module/dental-quote/dental-quote.component';
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';
import { MatTableModule } from '@angular/material/table';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatButtonModule } from '@angular/material/button';
import { DragNDropDirective } from './shared/directive/drag-n-drop.directive';
import { UnauthorizedComponent } from './shared/module/unauthorized/unauthorized.component';
import { HttpClientModule } from '@angular/common/http';
import { LoaderComponent } from './module/loader/loader/loader.component';
import { HomeComponent } from './module/home/home/home.component';
import { FormsModule } from '@angular/forms';
import { FileViewerComponent } from './module/file-viewer/file-viewer.component';

@NgModule({
  declarations: [
    AppComponent,
    FileUploadComponent,
    DentalQuoteComponent,
    DragNDropDirective,
    UnauthorizedComponent,
    LoaderComponent,
    HomeComponent,
    FileViewerComponent,
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    LDSFileUpload,
    LDSTable,
    MatTableModule,
    MatProgressBarModule,
    MatButtonModule,
    HttpClientModule,
    FormsModule,
  ],
  providers: [provideAnimationsAsync()],
  bootstrap: [AppComponent],
})
export class AppModule {}
